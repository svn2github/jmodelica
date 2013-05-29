package org.jmodelica.ide.sync;

import java.util.HashMap;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeListener;

public class ChangePropagationController {
	private static ChangePropagationController controller;

	// Each file has a Tree where listeners register against the file AST nodes.
	private HashMap<IFile, ListenerTreeNode> listenerTrees = new HashMap<IFile, ListenerTreeNode>();

	private boolean builderIsActive = false;

	private WorkspaceListener workspaceListener;

	private ChangePropagationController() {
	}

	public static synchronized ChangePropagationController getInstance() {
		if (controller == null)
			controller = new ChangePropagationController();
		return controller;
	}

	public synchronized void addListener(ListenerObject listObj, IFile file,
			Stack<ASTPathPart> nodePath) {
		ListenerTreeNode root = listenerTrees.get(file);
		if (root == null) {
			root = new ListenerTreeNode(null);
			listenerTrees.put(file, root);
		}
		ListenerTreeHandler.addListener(root, nodePath, listObj);
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
			Stack<ASTPathPart> nodePath) {
		ListenerTreeNode libroot = listenerTrees.get(file);
		if (libroot != null) {
			ListenerTreeHandler.handleChangedNode(file, changeType, libroot,
					nodePath);
		}
	}

	public synchronized boolean removeListener(IASTChangeListener listener,
			IFile file, Stack<ASTPathPart> nodePath) {
		if (file != null) {
			ListenerTreeNode root = listenerTrees.get(file);
			if (root != null) {
				boolean result = ListenerTreeHandler.removeListener(root,
						nodePath, listener);
				if (result)
					System.out
							.println("Successfully removed listener from file "
									+ file.getName());
				else
					System.out.println("Failed to remove listener from file "
							+ file.getName());
			}
		}
		return false;
	}

	/**
	 * Set when ModelicaBuilder is active, (i.e. when Eclipse
	 * "Build automatically" is set).
	 */
	public synchronized void setBuilderIsActive() {
		if (workspaceListener != null) {
			workspaceListener.dispose();
			workspaceListener = null;
		}
		builderIsActive = true;
	}

	/**
	 * Check if ModelicaBuilder is active.
	 */
	public synchronized void isBuilderActive() {
		if (!builderIsActive) {
			workspaceListener = new WorkspaceListener();
		}
	}
}