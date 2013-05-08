package org.jmodelica.ide.sync;

import java.util.ArrayList;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.ICompiler;
import org.jastadd.ed.core.model.GlobalRootRegistry;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.compiler.ModelicaEclipseCompiler;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.InstNode;
import org.jmodelica.modelica.compiler.InstProgramRoot;
import org.jmodelica.modelica.compiler.LibNode;
import org.jmodelica.modelica.compiler.Program;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class ModelicaASTRegistry extends GlobalRootRegistry {
	private static ModelicaASTRegistry registry;

	private ModelicaASTRegistry() {
	}

	public static synchronized ModelicaASTRegistry getInstance() {
		if (registry == null)
			registry = new ModelicaASTRegistry();
		return registry;
	}

	public void addListener(IFile file, Stack<String> nodePath,
			ListenerObject listObj) {
		ChangePropagationController.getInstance().addListener(listObj, file,
				nodePath);
	}

	public boolean removeListener(IFile file, Stack<ASTPathPart> nodePath,
			IASTChangeListener listener) {
		boolean result = ChangePropagationController.getInstance()
				.removeListener(listener, file, nodePath);
		String msg = result ? "successfully" : "failed to";
		System.out.println("ModelicaASTRegistry " + msg
				+ " unregistered listener: " + listener.toString()
				+ ", for file:" + file.getName() + " " + nodePath);
		return result;
	}

	/**
	 * Tries to resolve the node of the given path in Instance AST from the
	 * given InstProgramRoot. Needed if Instance Outline should have expandable
	 * nodes.
	 */
	public InstNode resolveInstanceASTPath(Stack<ASTPathPart> nodePath,
			InstNode root) {
		if (nodePath.size() == 0)
			return root;
		String sought = nodePath.pop().id();
		if (sought.substring(0, 5).equals("List:")) {
			InstNode node = searchClassesAndComponents(nodePath.pop().id(),
					root);
			return resolveInstanceASTPath(nodePath, node);
		}
		return null;
	}

	private InstNode searchClassesAndComponents(String peek, InstNode root) {
		ArrayList<InstNode> found = new ArrayList<InstNode>();
		found.addAll(root.instClassDecls());
		found.addAll(root.instComponentDecls());
		for (InstNode n : found)
			if (createIdentifier(n).equals(peek))
				return n;
		return null;
	}

	/**
	 * debug
	 */
	public void printPath(Stack<ASTPathPart> nodePath) {
		String priint = "";
		for (int i = 0; i < nodePath.size(); i++)
			priint = nodePath.get(i).id() + " " + priint;
		System.out.println("Nodepath was: " + priint);
	}

	/**
	 * Used to resolve AST paths for MSL components in Package Explorer. Starts
	 * looking from SourceRoot.
	 * 
	 * @return Found node, or SourceRoot if path was empty.
	 */
	public ASTNode<?> resolveSourceASTPath(Stack<ASTPathPart> nodePath,
			ASTNode<?> root) {
		String sought = "";
		String next = "";
		ASTNode<?> current = root;
		ASTNode<?> previous = null;
		int index = nodePath.size() - 1;
		while (index >= 0 && current != null) {
			next = "";
			previous = current;
			sought = nodePath.get(index).id();
			if (index > 0)
				next = nodePath.get(index - 1).id();
			current = findSrcChild(sought, next, current, previous);
			index--;
		}
		if (current == null) {
			System.err
					.println("ModelicaASTRegistry failed to resolve src nodepath...");
		}
		return current;
	}

	/**
	 * Bit messy, due to structure/location of MSL. If we are looking for a
	 * LibNode, and parent is a Program node, we need to search in the
	 * LibNodeList.
	 */
	private ASTNode<?> findSrcChild(String sought, String next,
			ASTNode<?> current, ASTNode<?> previous) {
		for (int i = 0; i < current.getNumChild(); i++) {
			ASTNode<?> currChild = current.getChild(i);
			if (sought.equals(createIdentifier(currChild)))
				return currChild;
		}
		if (!next.equals("") && next.substring(0, 8).equals("LibNode:")) {
			if (previous instanceof Program) {
				Program p = (Program) previous;
				if (createIdentifier(p.getLibNodeList()).equals(sought)) {
					return p.getLibNodeList();
				}
			}
		}
		if (sought.split(":")[0].equals("StoredDefinition")
				&& current instanceof LibNode) {
			return ((LibNode) current).getStoredDefinition();
		}
		return null;
	}

	/**
	 * Used to create AST paths for Instance Outline & MSL components in Package
	 * Explorer.
	 */
	public Stack<ASTPathPart> createPath(ASTNode<?> node) {
		Stack<ASTPathPart> nodePath = new Stack<ASTPathPart>();
		ASTNode<?> tmp = node;
		if (node instanceof InstNode) {
			while (tmp != null && !(tmp instanceof InstProgramRoot)) {
				ASTPathPart part = new ASTPathPart(createIdentifier(tmp),
						findIndex(tmp));
				nodePath.add(part);
				tmp = tmp.getParent();
			}
		} else {
			while (tmp != null && !(tmp instanceof SourceRoot)) {
				ASTPathPart part = new ASTPathPart(createIdentifier(tmp),
						findIndex(tmp));
				nodePath.add(part);
				tmp = tmp.getParent();
			}
		}
		return nodePath;
	}

	/**
	 * Creates the AST identifier path from an AST node to its parent
	 * StoredDefinition.
	 */
	public Stack<ASTPathPart> createDefPath(ASTNode<?> node) {
		Stack<ASTPathPart> nodePath = new Stack<ASTPathPart>();
		ASTNode<?> tmp = node;
		while (tmp != null && !(tmp instanceof StoredDefinition)) {
			ASTPathPart part = new ASTPathPart(createIdentifier(tmp),
					findIndex(tmp));
			nodePath.add(part);
			tmp = tmp.getParent();
		}
		return nodePath;
	}

	/**
	 * Finds the index of this node at its parent.
	 */
	private int findIndex(ASTNode<?> node) {
		return node.getParent().getIndexOfChild(node);
	}

	/**
	 * Creates a node identifier by concatenating
	 * "ASTNode.getNodeName():ASTNode.outlineId()".
	 */
	private String createIdentifier(ASTNode<?> node) {
		StringBuilder sb = new StringBuilder();
		sb.append(node.getNodeName());
		sb.append(":");
		sb.append(node.outlineId());
		return sb.toString();
	}

	@Override
	protected ICompiler createCompiler() {
		return new ModelicaEclipseCompiler();
	}

	/**
	 * Find the latest StoredDefinition for the given IFile.
	 */
	public StoredDefinition getLatestDef(IFile theFile) {
		return ((LocalRootNode) doLookup(theFile)[0]).getDef();
	}

	/**
	 * Resolves the given AST path within the given StoredDefinition, and
	 * returns the found AST node.
	 */
	public ASTNode<?> resolveSourceASTPath(StoredDefinition def,
			Stack<ASTPathPart> astPath) {
		ASTNode<?> tmp = def;
		for (int i = astPath.size() - 1; i >= 0; i--) {
			int index = astPath.get(i).index();
			if (astPath.get(i).id().substring(0, 5).equals("List:")) {
				tmp = tmp.getChild(index);
			} else {
				tmp = findChild(tmp, index, astPath.get(i).id());
				if (tmp == null)
					return null;
			}
		}
		return tmp;
	}

	/**
	 * Find the sought child node. Start at cached index, continue with closest
	 * neighbours and outwards.
	 */
	private ASTNode<?> findChild(ASTNode<?> tmp, int index, String string) {
		if (createIdentifier(tmp.getChild(index)).equals(string))
			return tmp.getChild(index);
		int numChild = tmp.getNumChild();
		int count = 0;
		while (count < numChild) {
			count++;
			if (index - count >= 0)
				if (createIdentifier(tmp.getChild(index - count))
						.equals(string))
					return tmp.getChild(index - count);
			if (index + count < numChild)
				if (createIdentifier(tmp.getChild(index + count))
						.equals(string))
					return tmp.getChild(index + count);
		}
		return null;
	}
}