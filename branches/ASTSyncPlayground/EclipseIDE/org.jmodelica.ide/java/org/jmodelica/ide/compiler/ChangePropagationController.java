package org.jmodelica.ide.compiler;

import java.util.Collections;
import java.util.HashMap;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeListener;

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

	public void addListener(ListenerObject listObj,
			IFile file, Stack<String> nodePath) {

		System.out.println("MODELICAASTREGISTRY: Added listener to file "
				+ file.getName());
		LibraryNode root = listenerTrees.get(file);
		if (root == null) {
			root = new LibraryNode(null);
			listenerTrees.put(file, root);
		}
		LibraryVisitor visitor = new LibraryVisitor();
		visitor.addListener(root, nodePath, listObj);
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
			Stack<String> nodePath) {
		LibraryNode libroot = listenerTrees.get(file);
		if (libroot != null) {
			LibraryVisitor visitor = new LibraryVisitor();
			Stack<String> copy = new Stack<String>();
			copy.setSize(nodePath.size());
			Collections.copy(copy, nodePath);
			visitor.handleChangedNode(changeType, libroot, copy);
		}
	}

	public void removeListener(IASTChangeListener listener, IFile file,
			Stack<String> nodePath) {
		LibraryNode root = listenerTrees.get(file);
		if (root != null) {
			LibraryVisitor visitor = new LibraryVisitor();
			visitor.removeListener(root, nodePath, listener);
		}
	}
}
