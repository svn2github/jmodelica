package org.jmodelica.ide.compiler;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.ASTChangeEvent;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.Access;
import org.jmodelica.modelica.compiler.Comment;
import org.jmodelica.modelica.compiler.ComponentDecl;
import org.jmodelica.modelica.compiler.ConnectClause;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.InstProgramRoot;
import org.jmodelica.modelica.compiler.Program;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class ModelicaASTRegistryVisitor {
	private ModelicaASTRegistry registry = ModelicaASTRegistry.getInstance();

	/**
	 * Default constructor. The {@link ModelicaASTRegistryVisitor} is
	 * instantiated by a job handler thread started by the
	 * {@link ModelicaASTRegistryJobBucket}, and will perform one
	 * {@link ModificationJob}.
	 */
	public ModelicaASTRegistryVisitor(ModificationJob job) {
		if (job != null) {
			int jobType = job.getJobType();
			if (jobType == IJobObject.REMOVE_NODE) {
				removeNode(job.getFile(), job.getModifyNodeASTPath());
			} else if (jobType == IJobObject.ADD_COMPONENT) {
				addNode(job);
			} else if (jobType == IJobObject.RENAME_NODE) {
				renameNode(job.getFile(), job.getModifyNodeASTPath(),
						job.getRenameName());
			} else if (jobType == IJobObject.ADD_CONNECTCLAUSE) {
				addConnectClause(job);
			} else if (jobType == IJobObject.REMOVE_CONNECTCLAUSE) {
				removeConnectClause(job);
			}
		}
	}

	private void removeConnectClause(ModificationJob job) {
		long time = System.currentTimeMillis();
		SourceRoot root = ((GlobalRootNode) registry.doLookup(job.getFile()
				.getProject())).getSourceRoot();
		synchronized (root.state()) {
			FullClassDecl fcd = (FullClassDecl) registry.resolveSourceASTPath(
					job.getClassASTPath(), root);
			ConnectClause connectClause = (ConnectClause) registry
					.resolveSourceASTPath(job.getModifyNodeASTPath(), root);
			fcd.removeEquation(connectClause);
			fcd.flushCache();
			fcd.components();
			fcd.classes();
			InstProgramRoot iRoot = root.getProgram().getInstProgramRoot();
			iRoot.flushCache();
			iRoot.classes(); // needed?
			iRoot.components();
		}
		ChangePropagationController.getInstance()
				.handleNotifications(ASTChangeEvent.POST_ADDED, job.getFile(),
						job.getClassASTPath());
		System.out
				.println("ModelicaASTRegVisitor: removing connectclause took: "
						+ (System.currentTimeMillis() - time) + "ms");
	}

	private void addConnectClause(ModificationJob job) {
		long time = System.currentTimeMillis();
		SourceRoot root = ((GlobalRootNode) registry.doLookup(job.getFile()
				.getProject())).getSourceRoot();
		synchronized (root.state()) {
			FullClassDecl fcd = (FullClassDecl) registry.resolveSourceASTPath(
					job.getClassASTPath(), root);
			ConnectClause connectClause = new ConnectClause();
			connectClause.setComment(new Comment());
			connectClause.setConnector1(Access.fromClassName(job
					.getSourceDiagramName()));
			connectClause.setConnector2(Access.fromClassName(job
					.getTargetDiagramName()));
			fcd.addNewEquation(connectClause);
			fcd.flushCache();
			fcd.components();
			fcd.classes();
			InstProgramRoot iRoot = root.getProgram().getInstProgramRoot();
			iRoot.flushCache();
			iRoot.classes(); // needed?
			iRoot.components();
		}
		ChangePropagationController.getInstance()
				.handleNotifications(ASTChangeEvent.POST_ADDED, job.getFile(),
						job.getClassASTPath());
		System.out.println("ModelicaASTRegVisitor: adding connectclause took: "
				+ (System.currentTimeMillis() - time) + "ms");
	}

	/**
	 * Rename the given node in both src and instance AST.
	 * 
	 * @param file
	 * @param instNode
	 */
	private void renameNode(IFile file, Stack<String> renameNodePath,
			String newName) {
		long time = System.currentTimeMillis();
		SourceRoot root = ((GlobalRootNode) registry
				.doLookup(file.getProject())).getSourceRoot();
		synchronized (root.state()) {
			ASTNode<?> srcNode = registry.resolveSourceASTPath(renameNodePath,
					root);
			if (srcNode instanceof FullClassDecl) {
				FullClassDecl decl = (FullClassDecl) srcNode;
				decl.getName().setID(newName);
			} else if (srcNode instanceof ComponentDecl) {
				ComponentDecl compdecl = (ComponentDecl) srcNode;
				compdecl.getName().setID(newName);
			}
			ChangePropagationController.getInstance().handleNotifications(
					ASTChangeEvent.POST_RENAME, file, renameNodePath);
		}
		System.out
				.println("ModelicaAstReg: RenameJob+handling/starting notification threads took: "
						+ (System.currentTimeMillis() - time) + "ms");
	}

	/**
	 * Add a node to source and instance AST.
	 * 
	 * @param file
	 * @param node
	 */
	private void addNode(ModificationJob job) {
		long time = System.currentTimeMillis();
		SourceRoot root = ((GlobalRootNode) registry.doLookup(job.getFile()
				.getProject())).getSourceRoot();
		synchronized (root.state()) {
			IFile file = job.getFile();
			System.out.println("MODELICAASTREGVISITOR addnode ist...: "
					+ job.getClassName());
			FullClassDecl fcd = (FullClassDecl) registry.resolveSourceASTPath(
					job.getClassASTPath(), root);

			System.out.println("ADDNODE: className:" + job.getClassName()
					+ " componentname:" + job.getComponentName());
			fcd.syncAddComponent(job.getClassName(), job.getComponentName(),
					job.getPlacement());

			LocalRootNode lr = (LocalRootNode) registry.doLookup(file)[0];
			StoredDefinition def = lr.getDef();

			SourceRoot sr = (SourceRoot) def.root();
			Program pr = sr.getProgram();
			InstProgramRoot iRoot = pr.getInstProgramRoot();
			iRoot.flushCache();
			iRoot.classes(); // needed?
			iRoot.components();
			ChangePropagationController.getInstance().handleNotifications(
					ASTChangeEvent.POST_ADDED, file, job.getClassASTPath());
		}
		System.out
				.println("ModelicaAstReg: AddJob+handling/starting notification threads took: "
						+ (System.currentTimeMillis() - time) + "ms");
	}

	/**
	 * Removes a node from the source and instance AST.
	 * 
	 * @param file
	 * @param instNode
	 */
	private void removeNode(IFile file, Stack<String> removeNodePath) {
		long time = System.currentTimeMillis();
		SourceRoot root = ((GlobalRootNode) registry
				.doLookup(file.getProject())).getSourceRoot();
		synchronized (root.state()) {
			ASTNode<?> srcNode = registry.resolveSourceASTPath(removeNodePath,
					root);
			removeSrcNode(srcNode);
			LocalRootNode lr = (LocalRootNode) registry.doLookup(file)[0];
			StoredDefinition def = lr.getDef();

			SourceRoot sr = (SourceRoot) def.root();
			Program pr = sr.getProgram();
			InstProgramRoot iRoot = pr.getInstProgramRoot();
			iRoot.flushCache();

			// TODO probably want project as identifier also?
			// TODO removeListenerPath(file, nodePath);

			ChangePropagationController.getInstance().handleNotifications(
					ASTChangeEvent.POST_REMOVE, file, removeNodePath);
		}
		System.out
				.println("ModelicaAstReg: RemoveJob+handling/starting notification threads took: "
						+ (System.currentTimeMillis() - time) + "ms");
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
			while (parent.getParent() != null
					&& !(parent instanceof FullClassDecl)) {
				parent = parent.getParent();
			}
			if (parent instanceof FullClassDecl) {
				FullClassDecl decl = (FullClassDecl) parent;
				decl.removeComponentDecl(comp);
				decl.flushCache();
				decl.components();

				System.out
						.println("SUCCESSFULLY REMOVED COMPONENTDECL FROM FULLCLASSDECL");
			}
		}
	}

	/**
	 * Returns the node in the source tree corresponding to the selected
	 * instance tree node.
	 * 
	 * @param selectedInstNode
	 * @return
	 */
	/**
	 * private ASTNode<?> getCorrespondingSrcNode(ASTNode<?> selectedInstNode) {
	 * ASTNode<?> result = null; if (selectedInstNode instanceof InstClassDecl)
	 * { InstClassDecl decl = (InstClassDecl) selectedInstNode; result =
	 * decl.getClassDecl(); } else if (selectedInstNode instanceof
	 * InstComponentDecl) { InstComponentDecl decl = (InstComponentDecl)
	 * selectedInstNode; result = decl.getComponentDecl(); } if (result == null)
	 * { System.err.println("getCorrespondingSrcnode failed..."); } return
	 * result; // return selectedInstNode.getSelectionNode(); }
	 */

	/**
	 * Returns an arraylist with the path from given node to root. Each node has
	 * its name + outlineid as identifier. Lists have the child index of path as
	 * outlineid.
	 * 
	 * @param node
	 * @return
	 */
	/**
	 * private ArrayList<String> getNodePathToRoot(ASTNode<?> node) {
	 * ArrayList<String> nodePath = new ArrayList<String>();
	 * ArrayList<ASTNode<?>> visited = new ArrayList<ASTNode<?>>(); ASTNode<?>
	 * previousNode = null; while (node != null && !visited.contains(node)) {
	 * visited.add(node); String newPath = ""; if (node instanceof List &&
	 * previousNode != null) { int index = node.getIndexOfChild(previousNode);
	 * newPath = node.getNodeName() + " " + index; } else { newPath =
	 * getNodeName(node); } nodePath.add(newPath); previousNode = node; node =
	 * node.getParent(); } return nodePath; }
	 */

	/**
	 * Returns the node type and id used as unique identifier.
	 * 
	 * @param node
	 * @return
	 */
	/**
	 * private String getNodeName(ASTNode<?> node) { String name =
	 * node.getNodeName() + " " + node.outlineId(); return name; }
	 */

	/*
	 * private void removeNodeFromSrcClassUses(ASTNode<?> component, String
	 * className) { ASTNode<?> root = component; while (root.getParent() !=
	 * null) root = root.getParent(); ArrayList<ComponentDecl> foundAccesses =
	 * new ArrayList<ComponentDecl>(); findAllClassUsesInSrcAST(root, className,
	 * foundAccesses); System.out.println("REMOVE FOUND nbr srcclassaccesses: "
	 * + foundAccesses.size()); for (ComponentDecl classAccess : foundAccesses)
	 * { removeSrcChild(component, classAccess); } }
	 */

	/**
	 * Remove the component from the classAccess
	 * 
	 * @param component
	 *            child
	 * @param classAccess
	 *            parent
	 */
	/*
	 * private void removeSrcChild(ASTNode<?> component, ComponentDecl
	 * classAccess) { // TODO make this work }
	 */

	// DEBUG TODO remove
	/*
	 * private void debugPrintFullAST(ASTNode<?> root, String indent,
	 * ArrayList<ASTNode<?>> visited) { if (indent.equals("")) {
	 * System.out.println(root.getNodeName() + " " + root.outlineId());
	 * visited.add(root); } else { for (int i = 0; i < root.getNumChild(); i++)
	 * { ASTNode<?> child = root.getChild(i); System.out.println(indent +
	 * child.getNodeName() + " " + child.outlineId()); } } for (int i = 0; i <
	 * root.getNumChild(); i++) { ASTNode<?> child = root.getChild(i); if
	 * (!visited.contains(child)) { visited.add(child); debugPrintFullAST(child,
	 * indent + "  ", visited); } } }
	 */

	// DEBUG TODO remove
	/*
	 * private void printSubTree(ASTNode<?> node, String indent) { System.out
	 * .println(indent + node.getNodeName() + " " + node.outlineId()); for (int
	 * i = 0; i < node.getNumChild(); i++) { printSubTree(node.getChild(i),
	 * indent + "  "); } }
	 */

	// DEBUG TODO remove
	/*
	 * private String printPath(ArrayList<String> list) { String res = ""; for
	 * (int i = 0; i < list.size(); i++) { if (res.equals("")) { res =
	 * list.get(i); } else { res = res + " /// " + list.get(i); } } return res;
	 * }
	 */
	/**
	 * Add instcomponent to all instclass uses in instAST.
	 * 
	 * @param srcNode
	 * @param surroundingClassName
	 */
	/*
	 * private void addNodeToSrcClassUses(ASTNode<?> srcNode, String
	 * surroundingClassName) { ArrayList<ComponentDecl> srcUses = new
	 * ArrayList<ComponentDecl>(); ASTNode<?> root = srcNode; while
	 * (root.getParent() != null) root = root.getParent(); // TODO might need to
	 * keep track of visited // nodes so not infinite loop, maybe // better to
	 * get root via lookup(file) findAllClassUsesInSrcAST(root,
	 * surroundingClassName, srcUses); System.out
	 * .println("addnode findAllClassUsesInInstAST() found nbr uses: " +
	 * srcUses.size()); for (ComponentDecl decl : srcUses) { //
	 * decl.addChild(srcNode); ASTNode<?> tmp = decl; while (!(tmp instanceof
	 * FullClassDecl)) { tmp = tmp.getParent(); } FullClassDecl fcd =
	 * (FullClassDecl) tmp; // fcd.flushCache(); //TODO we need? //
	 * fcd.classes(); //TODO we need? fcd.components(); // TODO addComponent,
	 * addchild is prob very // bad way to add? } }
	 */

	/**
	 * Add the new component to all class uses within the instance tree.
	 * 
	 * @param file
	 * @param instNode
	 * @param className
	 */
	/*
	 * private void addNodeToInstClassUses(IFile file, InstComponentDecl
	 * instNode, String className) { ArrayList<InstComponentDecl> foundAccesses
	 * = findAllClassUsesInInstAST( file, className); for (InstComponentDecl icd
	 * : foundAccesses) { icd.addInstComponentDecl(instNode); } }
	 */

	/**
	 * Removes a node from the instance AST.
	 * 
	 * @param instNode
	 */
	/*
	 * private void removeInstNode(ASTNode<?> instNode) { if (instNode
	 * instanceof InstComponentDecl) { System.out
	 * .println("ModelicaASTRegVISITOR: REMOVENODE was instcompdecl");
	 * InstComponentDecl decl = (InstComponentDecl) instNode; ASTNode<?> parent
	 * = decl.getParent(); while (parent != null && !(parent instanceof
	 * InstClassDecl)) { parent = parent.getParent(); } if (parent instanceof
	 * InstClassDecl) { InstClassDecl classdecl = (InstClassDecl) parent;
	 * classdecl.removeInstComponentDecl(decl); System.out
	 * .println("ModelicaASTRegVISITOR: succ removed instcompdecl from instclass"
	 * ); } }// TODO only support remove components? (class, model, eg...) }
	 */

	/*
	 * private void removeNodeFromInstClassUses(IFile file, String className,
	 * InstComponentDecl component) { ArrayList<InstComponentDecl> foundAccesses
	 * = findAllClassUsesInInstAST( file, className);
	 * System.out.println("REMOVE FOUND nbr instclassaccesses: " +
	 * foundAccesses.size()); for (InstComponentDecl classAccess :
	 * foundAccesses) { removeInstChild(component, classAccess); } }
	 */

	/**
	 * Remove the component from the classAccess.
	 * 
	 * @param component
	 *            child
	 * @param classAccess
	 *            parent
	 */
	/*
	 * private void removeInstChild(InstComponentDecl component,
	 * InstComponentDecl classAccess) { List<InstComponentDecl> classComponents
	 * = classAccess .getInstComponentDecls(); for (int i = 0; i <
	 * classComponents.getNumChild(); i++) { if
	 * (classComponents.getChild(i).equals(component)) {
	 * classAccess.removeChild(i); break; } } }
	 */

	/**
	 * TODO probably needs refactoring, complexity > 1000
	 * 
	 * @param file
	 * @param className
	 * @return
	 */
	/*
	 * private ArrayList<InstComponentDecl> findAllClassUsesInInstAST(IFile
	 * file, String className) { ArrayList<InstComponentDecl> foundAccesses =
	 * new ArrayList<InstComponentDecl>(); LocalRootNode lroot = (LocalRootNode)
	 * ModelicaASTRegistry .getASTRegistry().doLookup(file)[0]; StoredDefinition
	 * def = lroot.getDef(); InstProgramRoot iRoot =
	 * lroot.getSourceRoot().getProgram() .getInstProgramRoot(); ArrayList<?>
	 * classes = def.getElements().toArrayList(); for (InstClassDecl inst :
	 * iRoot.instClassDecls()) { if (classes.contains(inst.getClassDecl())) { //
	 * No accesses within declaring class, would give infinite loop // (?) if
	 * (!(inst.outlineId().equals(className))) { List<InstComponentDecl>
	 * complist = inst .getInstComponentDecls(); for (InstComponentDecl idecl :
	 * complist) { InstAccess ia = idecl.getClassName(); if (ia instanceof
	 * InstClassAccess) { InstClassAccess ica = (InstClassAccess) ia; if
	 * (ica.getID().equals(className)) { //
	 * idecl.addInstComponentDecl(instNode); foundAccesses.add(idecl);
	 * System.out .println("ooooOOO found instclassacccess"); } } } } } }
	 * System.out.println("findAllClassUsesInInstAST() found nbr uses: " +
	 * foundAccesses.size()); return foundAccesses; }
	 */

	/**
	 * Rename all the found class accesses. Renaming is properly propagated to
	 * all class accesses automagically.
	 * 
	 * @param foundAccesses
	 */
	/*
	 * private void renameFoundClassAccesses(ArrayList<ComponentDecl>
	 * foundAccesses) { for (ComponentDecl decl : foundAccesses) { Access ca =
	 * decl.getClassName(); ClassAccess theaccess = (ClassAccess) ca;
	 * theaccess.setID("CHANGEDNAME"); } }
	 */

	/**
	 * Find all class uses within the src AST.
	 * 
	 * @param root
	 * @param className
	 * @param foundAccesses
	 */
	/*
	 * private void findAllClassUsesInSrcAST(IASTNode root, String className,
	 * ArrayList<ComponentDecl> foundAccesses) { for (int i = 0; i <
	 * root.getNumChild(); i++) { IASTNode child = root.getChild(i); if (child
	 * instanceof FullClassDecl) { FullClassDecl fcd = (FullClassDecl) child;
	 * for (ComponentDecl decl : fcd.getComponentDeclList()) { Access access =
	 * decl.getClassName(); if (access instanceof ClassAccess) { ClassAccess ca
	 * = (ClassAccess) access; if (ca.getID().equals(className)) {
	 * System.out.println("Found SrcClassAccess: " + ca.getNodeName());
	 * foundAccesses.add(decl); } } } } else { findAllClassUsesInSrcAST(child,
	 * className, foundAccesses); } } }
	 */

	// DEBUG TODO remove
	/*
	 * private String makeStringOfArrayPath(ArrayList<String> list) { String res
	 * = ""; for (int i = 0; i < list.size(); i++) { if (res.equals("")) { res =
	 * list.get(i); } else { res = res + " /// " + list.get(i); } } return res;
	 * }
	 */
}
