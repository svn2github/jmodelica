package org.jmodelica.ide.compiler;

import java.util.ArrayList;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.ASTChangeEvent;
import org.jastadd.ed.core.model.node.IASTNode;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.Access;
import org.jmodelica.modelica.compiler.ClassAccess;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.ComponentDecl;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.InstAccess;
import org.jmodelica.modelica.compiler.InstClassAccess;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstComponentDecl;
import org.jmodelica.modelica.compiler.InstProgramRoot;
import org.jmodelica.modelica.compiler.List;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class ModelicaASTRegistryVisitor {
	private ModelicaASTRegistry registry = ModelicaASTRegistry.getASTRegistry();

	/**
	 * Default constructor. The {@link ModelicaASTRegistryVisitor} will
	 * automatically retrieve and process one job, if an available job exist at
	 * the {@link ModelicaASTRegistryJobBucket}.
	 */
	public ModelicaASTRegistryVisitor() {
		doOneJob();
	}

	/**
	 * Retrieves and processes one job, if an available job exist at the
	 * {@link ModelicaASTRegistryJobBucket}.
	 */
	private void doOneJob() {
		JobObject job = ModelicaASTRegistryJobBucket.getInstance().getJob();
		if (job != null) {
			int jobType = job.getJobType();
			if (jobType == JobObject.REMOVE_INSTNODE) {
				removeNode(job.getFile(), job.getNode());
			} else if (jobType == JobObject.ADD_NODE) {
				addNode(job.getFile(), job.getNode());
			} else if (jobType == JobObject.RENAME_NODE) {
				renameNode(job.getFile(), job.getNode());
			}
		}
	}

	/**
	 * Rename the given node in both src and instance AST.
	 * 
	 * @param file
	 * @param instNode
	 */
	private void renameNode(IFile file, ASTNode<?> instNode) {
		System.out.println("MODELICAASTREGVISITOR renamenode ist...: "
				+ getNodeName(instNode));
		ASTNode<?> srcNode = getCorrespondingSrcNode(instNode);

		if (srcNode instanceof FullClassDecl) {
			FullClassDecl decl = (FullClassDecl) srcNode;
			String soughtName = "ClassAccess: '" + srcNode.outlineId() + "'";
			decl.getName().setID("CHANGEDNAME");
			IASTNode root = decl;
			while (root.getParent() != null)
				root = root.getParent();
			ArrayList<ComponentDecl> foundAccesses = new ArrayList<ComponentDecl>();
			findAllClassUsesInSrcAST(root, soughtName, foundAccesses);
			renameFoundClassAccesses(foundAccesses);
		} else if (srcNode instanceof ComponentDecl) {
			ComponentDecl compdecl = (ComponentDecl) srcNode;
			compdecl.getName().setID("CHANGEDNAME");// TODO fix hardcoded
													// name...
		}
		ASTNode<?> root = srcNode;
		while (root.getParent() != null)
			root = root.getParent();
		printSubTree(root, "");
		ArrayList<String> nodePath = getNodePathToRoot(srcNode);
		LibraryVisitor visitor = new LibraryVisitor();
		LibraryNode libroot = registry.getListenerTree(file);
		visitor.handleChangedNode(ASTChangeEvent.POST_RENAME, libroot,
				nodePath, srcNode);
	}

	/**
	 * Find all class uses within the src AST.
	 * 
	 * @param root
	 * @param className
	 * @param foundAccesses
	 */
	private void findAllClassUsesInSrcAST(IASTNode root, String className,
			ArrayList<ComponentDecl> foundAccesses) {
		for (int i = 0; i < root.getNumChild(); i++) {
			IASTNode child = root.getChild(i);
			if (child instanceof FullClassDecl) {
				FullClassDecl fcd = (FullClassDecl) child;
				for (ComponentDecl decl : fcd.getComponentDeclList()) {
					Access access = decl.getClassName();
					if (access instanceof ClassAccess) {
						ClassAccess ca = (ClassAccess) access;
						if (ca.getID().equals(className)) {
							System.out.println("Found SrcClassAccess: "
									+ ca.getNodeName());
							foundAccesses.add(decl);
						}
					}
				}
			} else {
				findAllClassUsesInSrcAST(child, className, foundAccesses);
			}
		}
	}

	/**
	 * Rename all the found class accesses.
	 * 
	 * @param foundAccesses
	 */
	private void renameFoundClassAccesses(ArrayList<ComponentDecl> foundAccesses) {
		for (ComponentDecl decl : foundAccesses) {
			Access ca = decl.getClassName();
			ClassAccess theaccess = (ClassAccess) ca;
			theaccess.setID("CHANGEDNAME");
		}
	}

	/**
	 * Add a node to source and instance AST.
	 * 
	 * @param file
	 * @param node
	 */
	private void addNode(IFile file, ASTNode<?> instNode) {
		System.out.println("MODELICAASTREGVISITOR addnode ist...: "
				+ getNodeName(instNode));
		printSubTree(instNode, "");
		ASTNode<?> srcNode = getCorrespondingSrcNode(instNode);
		if (instNode instanceof InstComponentDecl) {
			InstComponentDecl icd = (InstComponentDecl) instNode;
			String surroundingClassName = getFullClassDeclName(srcNode);

			addNodeToSrcClassUses(srcNode, surroundingClassName);
			addNodeToInstClassUses(file, icd, surroundingClassName);
		} // TODO can we add other stuff?
		ArrayList<String> srcNodePath = getNodePathToRoot(srcNode);
		System.out.println("TestADDAction: PATH OF SRCNODE WAS: "
				+ makeStringOfArrayPath(srcNodePath));
		LibraryVisitor visitor = new LibraryVisitor();
		LibraryNode libroot = registry.getListenerTree(file);
		visitor.handleChangedNode(ASTChangeEvent.POST_ADDED, libroot,
				srcNodePath, instNode);
	}

	/**
	 * Add instcomponent to all instclass uses in instAST.
	 * 
	 * @param srcNode
	 * @param surroundingClassName
	 */
	private void addNodeToSrcClassUses(ASTNode<?> srcNode,
			String surroundingClassName) {
		ArrayList<ComponentDecl> srcUses = new ArrayList<ComponentDecl>();
		ASTNode<?> root = srcNode;
		while (root.getParent() != null)
			root = root.getParent(); // TODO might need to keep track of visited
										// nodes so not infinite loop, maybe
										// better to get root via lookup(file)
		findAllClassUsesInSrcAST(root, surroundingClassName, srcUses);
		for (ComponentDecl decl : srcUses) {
			decl.addChild(srcNode); //TODO addComponent, addchild is prob very bad way to add?
		}
	}

	/**
	 * Add the new component to all class uses within the instance tree. TODO
	 * probably needs refactoring, complexity > 1000
	 * 
	 * @param file
	 * @param instNode
	 * @param className
	 */
	private void addNodeToInstClassUses(IFile file, InstComponentDecl instNode,
			String className) {
		LocalRootNode lroot = (LocalRootNode) ModelicaASTRegistry
				.getASTRegistry().doLookup(file)[0];
		StoredDefinition def = lroot.getDef();
		InstProgramRoot iRoot = lroot.getSourceRoot().getProgram()
				.getInstProgramRoot();
		ArrayList<?> classes = def.getElements().toArrayList();
		for (InstClassDecl inst : iRoot.instClassDecls()) {
			if (classes.contains(inst.getClassDecl())) {
				// No accesses within declaring class, would give infinite loop
				// (?)
				if (!(inst.outlineId().equals(className))) {
					List<InstComponentDecl> complist = inst
							.getInstComponentDecls();
					for (InstComponentDecl idecl : complist) {
						InstAccess ia = idecl.getClassName();
						if (ia instanceof InstClassAccess) {
							InstClassAccess ica = (InstClassAccess) ia;
							if (ica.getID().equals(className)) {
								idecl.addInstComponentDecl(instNode);
								System.out
										.println("ooooOOO added instNode to instcompdecl");
							}
						}
					}
				}
			}
		}
	}

	/**
	 * Get the outlineid() of the nodes surrounding FullClassdecl.
	 * 
	 * @param srcNode
	 * @return
	 */
	private String getFullClassDeclName(ASTNode<?> srcNode) {
		srcNode = srcNode.getParent();
		while (srcNode != null && !(srcNode instanceof FullClassDecl)) {
			srcNode = srcNode.getParent();
		}
		return srcNode.outlineId();
	}

	/**
	 * Removes a node from the source and instance AST. TODO also remove from
	 * all class accesses.
	 * 
	 * @param file
	 * @param instNode
	 */
	private void removeNode(IFile file, ASTNode<?> instNode) {
		ASTNode<?> srcNode = getCorrespondingSrcNode(instNode);
		ArrayList<String> nodePath = getNodePathToRoot(srcNode);

		ArrayList<String> instNodePath = getNodePathToRoot(instNode);
		System.out.println("TestRemoveAction: PATH OF INSTNODE WAS: "
				+ makeStringOfArrayPath(instNodePath));
		ASTNode<?> selectedSrcNode = getCorrespondingSrcNode(instNode);
		ArrayList<String> srcNodePath = getNodePathToRoot(selectedSrcNode);
		System.out.println("TestRemoveAction: PATH OF SRCNODE WAS: "
				+ makeStringOfArrayPath(srcNodePath));

		removeInstNode(instNode);
		removeSrcNode(srcNode);
		System.out.println("ModelicaASTRegVISITOR: recieved remove job!");
		System.out.println("ModelicaASTRegVISITOR: nodePath was: "
				+ printPath(nodePath));

		// TODO probably need project as identifier also?
		// TODO removeListenerPath(file, nodePath);
		LibraryVisitor visitor = new LibraryVisitor();
		LibraryNode libroot = registry.getListenerTree(file);
		visitor.handleChangedNode(ASTChangeEvent.POST_REMOVE, libroot,
				nodePath, instNode);
	}

	/**
	 * Removes a node from the instance AST.
	 * 
	 * @param instNode
	 */
	private void removeInstNode(ASTNode<?> instNode) {
		if (instNode instanceof InstComponentDecl) {
			System.out
					.println("ModelicaASTRegVISITOR: REMOVENODE was instcompdecl");
			InstComponentDecl decl = (InstComponentDecl) instNode;
			ASTNode<?> parent = decl.getParent();
			while (parent != null && !(parent instanceof InstClassDecl)) {
				parent = parent.getParent();
			}
			if (parent instanceof InstClassDecl) {
				InstClassDecl classdecl = (InstClassDecl) parent;
				classdecl.removeInstComponentDecl(decl);
				System.out
						.println("ModelicaASTRegVISITOR: succ removed instcompdecl from instclass");
			}
		}// TODO only support remove components? (class, model, eg...)
	}

	/**
	 * Returns the node in the source tree corresponding to the selected
	 * instance tree node.
	 * 
	 * @param selectedInstNode
	 * @return
	 */
	private ASTNode<?> getCorrespondingSrcNode(ASTNode<?> selectedInstNode) {
		ASTNode<?> result = null;
		if (selectedInstNode instanceof InstClassDecl) {
			InstClassDecl decl = (InstClassDecl) selectedInstNode;
			result = decl.getClassDecl();
		} else if (selectedInstNode instanceof InstComponentDecl) {
			InstComponentDecl decl = (InstComponentDecl) selectedInstNode;
			result = decl.getComponentDecl();
		}
		return result;
		// return selectedInstNode.getSelectionNode();
	}

	/**
	 * Returns an arraylist with the path from given node to root. Each node has
	 * its name + outlineid as identifier. Lists have the child index of path as
	 * outlineid.
	 * 
	 * @param node
	 * @return
	 */
	private ArrayList<String> getNodePathToRoot(ASTNode<?> node) {
		ArrayList<String> nodePath = new ArrayList<String>();
		ArrayList<ASTNode<?>> visited = new ArrayList<ASTNode<?>>();
		ASTNode<?> previousNode = null;
		while (node != null && !visited.contains(node)) {
			visited.add(node);
			String newPath = "";
			if (node instanceof List && previousNode != null) {
				int index = node.getIndexOfChild(previousNode);
				newPath = node.getNodeName() + " " + index;
			} else {
				newPath = getNodeName(node);
			}
			nodePath.add(newPath);
			previousNode = node;
			node = node.getParent();
		}
		return nodePath;
	}

	/**
	 * Returns the node type and id used as unique identifier.
	 * 
	 * @param node
	 * @return
	 */
	private String getNodeName(ASTNode<?> node) {
		String name = node.getNodeName() + " " + node.outlineId();
		return name;
	}

	/**
	 * Removes a node from the source AST.
	 * 
	 * @param theNode
	 */
	private void removeSrcNode(ASTNode<?> theNode) {
		if (theNode instanceof ComponentDecl) {
			ComponentDecl comp = (ComponentDecl) theNode;
			ASTNode<?> parent = comp.getParent();
			while (parent.getParent() != null && !(parent instanceof ClassDecl)) {
				parent = parent.getParent();
			}
			if (parent instanceof FullClassDecl) {
				FullClassDecl decl = (FullClassDecl) parent;
				decl.removeComponentDecl(comp);
				System.out
						.println("SUCCESSFULLY REMOVED COMPONENTDECL FROM FULLCLASSDECL");
			}
		}/*
		 * else { //TODO only support remove component? ASTNode<?> parent =
		 * theNode.getParent(); int myIndex = parent.getIndexOfChild(theNode);
		 * parent.removeChild(myIndex); }
		 */
	}

	// DEBUG TODO remove
	private void debugPrintFullAST(ASTNode<?> root, String indent,
			ArrayList<ASTNode<?>> visited) {
		if (indent.equals("")) {
			System.out.println(root.getNodeName() + " " + root.outlineId());
			visited.add(root);
		} else {
			for (int i = 0; i < root.getNumChild(); i++) {
				ASTNode<?> child = root.getChild(i);
				System.out.println(indent + child.getNodeName() + " "
						+ child.outlineId());
			}
		}
		for (int i = 0; i < root.getNumChild(); i++) {
			ASTNode<?> child = root.getChild(i);
			if (!visited.contains(child)) {
				visited.add(child);
				debugPrintFullAST(child, indent + "  ", visited);
			}
		}
	}

	// DEBUG TODO remove
	private void printSubTree(ASTNode<?> node, String indent) {
		System.out
				.println(indent + node.getNodeName() + " " + node.outlineId());
		for (int i = 0; i < node.getNumChild(); i++) {
			printSubTree(node.getChild(i), indent + "  ");
		}
	}

	// DEBUG TODO remove
	private String printPath(ArrayList<String> list) {
		String res = "";
		for (int i = 0; i < list.size(); i++) {
			if (res.equals("")) {
				res = list.get(i);
			} else {
				res = res + " /// " + list.get(i);
			}
		}
		return res;
	}

	// DEBUG TODO remove
	private String makeStringOfArrayPath(ArrayList<String> list) {
		String res = "";
		for (int i = 0; i < list.size(); i++) {
			if (res.equals("")) {
				res = list.get(i);
			} else {
				res = res + " /// " + list.get(i);
			}
		}
		return res;
	}
}
