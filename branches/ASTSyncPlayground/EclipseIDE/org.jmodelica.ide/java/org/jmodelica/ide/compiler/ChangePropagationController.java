package org.jmodelica.ide.compiler;

import java.util.HashMap;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.modelica.compiler.ASTNode;

public class ChangePropagationController {
	private static ChangePropagationController controller;

	// Each file has a Tree where listeners register against the file ast nodes.
	// TODO synchronize when handling listeners
	private HashMap<IFile, LibraryNode> listenerTrees = new HashMap<IFile, LibraryNode>();

	private ChangePropagationController() {
	}

	public static synchronized ChangePropagationController getInstance() {
		if (controller == null)
			controller = new ChangePropagationController();
		return controller;
	}

	public void addListener(IFile file, ASTNode<?> node,
			IASTChangeListener listener, int listenerType, Stack<String> nodePath) {

		System.out.println("MODELICAASTREGISTRY: Added listener to file "
				+ file.getName());
		LibraryNode root = listenerTrees.get(file);
		if (root == null) {
			root = new LibraryNode(null);
			listenerTrees.put(file, root);
		}
		LibraryVisitor visitor = new LibraryVisitor();
		visitor.addListener(root, nodePath, listener, listenerType);
	}

	/**
	 * 
	 * @param changeType
	 *            ASTChangeEvent.type
	 * @param file
	 * @param srcNode
	 * @param nodePath
	 */
	public synchronized void handleNotifications(int changeType, IFile file,
			ASTNode<?> srcNode, Stack<String> nodePath) {
		LibraryVisitor visitor = new LibraryVisitor();
		LibraryNode libroot = listenerTrees.get(file);
		visitor.handleChangedNode(changeType, libroot, nodePath, srcNode);
	}
}
