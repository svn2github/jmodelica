package org.jmodelica.ide.sync;

import java.util.ArrayList;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeListener;

public class ListenerTreeHandler {
	/**
	 * Notify listeners of changed resource path.
	 * 
	 * @param root
	 * @param nodePath
	 */
	public static void handleChangedNode(IFile file, int astChangeEventType,
			ListenerTreeNode root, Stack<ASTPathPart> nodePath) {
		ArrayList<ListenerObject> affectedListeners = new ArrayList<ListenerObject>();
		getAllAffectedListeners(nodePath.size() - 1, root, nodePath,
				affectedListeners);
		for (ListenerObject obj : affectedListeners) {
			obj.doUpdate(file, astChangeEventType, nodePath);
		}
	}

	private static ListenerTreeNode resolvePath(Stack<ASTPathPart> nodePath,
			ListenerTreeNode root) {
		if (nodePath == null || nodePath.isEmpty()) {
			return root;
		}
		return resolvePath(nodePath, root, nodePath.size() - 1);
	}

	private static ListenerTreeNode resolvePath(Stack<ASTPathPart> nodePath,
			ListenerTreeNode root, int index) {
		String id = nodePath.get(index).id();
		// We don't care 'bout list nodes
		if (id.substring(0, 5).equals("List:"))
			return resolvePath(nodePath, root, index - 1);
		ListenerTreeNode child = findChild(nodePath.get(index).id(), root);
		if (child == null || index == 0)
			return child;
		return resolvePath(nodePath, child, index - 1);
	}

	private static ListenerTreeNode resolvePathCreate(
			Stack<ASTPathPart> nodePath, ListenerTreeNode root, int index) {
		String id = nodePath.get(index).id();
		// We don't care 'bout list nodes
		if (id.substring(0, 5).equals("List:"))
			return resolvePathCreate(nodePath, root, index - 1);
		ListenerTreeNode child = findChild(nodePath.get(index).id(), root);
		if (child == null) {
			// No previous listeners along this path, create a
			// new child node.
			child = new ListenerTreeNode(id);
			root.addChild(child);
		}
		if (index == 0)
			return child;
		return resolvePathCreate(nodePath, child, index - 1);
	}

	private static ListenerTreeNode findChild(String id, ListenerTreeNode parent) {
		for (ListenerTreeNode node : parent.getChildren())
			if (node.getId().equals(id))
				return node;
		return null;
	}

	/**
	 * If sought node is not this node, continue down in tree in accordance with
	 * nodePath. When correct node is found, register listener.
	 * 
	 * @param node
	 * @param nodePath
	 * @param listener
	 * @param astChangeListenerType
	 */
	public static void addListener(ListenerTreeNode root,
			Stack<ASTPathPart> nodePath, ListenerObject listObj) {
		if (nodePath == null || nodePath.size() == 0) {
			root.addListener(listObj);
		} else {
			ListenerTreeNode node = resolvePathCreate(nodePath, root,
					nodePath.size() - 1);
			node.addListener(listObj);
		}
	}

	/**
	 * Return all nodes that listen to this and any other node along this path.
	 * And also all listeners of nodes in the subtree where last node of path is
	 * root.
	 * 
	 * @param node
	 * @param nodePath
	 * @return
	 */
	public static void getAllAffectedListeners(int index,
			ListenerTreeNode node, Stack<ASTPathPart> nodePath,
			ArrayList<ListenerObject> listenerlist) {
		if (index > 0) { // Collect listeners of nodes along path
			collectVisitorsAndMoveOn(index, node, nodePath, listenerlist);
		} else if (index <= 0) { // Collect listeners in subtree under
									// last node of path
			collectAllListenersInSubtree(node, listenerlist);
		}
	}

	/**
	 * Collects all listeners in this node and continues to the appropriate
	 * child node
	 * 
	 * @param node
	 * @param nodePath
	 * @param listenerlist
	 * @return
	 */
	private static void collectVisitorsAndMoveOn(int index,
			ListenerTreeNode node, Stack<ASTPathPart> nodePath,
			ArrayList<ListenerObject> listenerlist) {
		String soughtNodeId = nodePath.get(index).id();
		if (soughtNodeId.substring(0, 5).equals("List:")) {
			collectVisitorsAndMoveOn(index - 1, node, nodePath, listenerlist);
		} else {
			listenerlist.addAll(node.getListeners());
			for (ListenerTreeNode child : node.getChildren()) {
				if (child.getId().equals(soughtNodeId)) {
					getAllAffectedListeners(index - 1, child, nodePath,
							listenerlist);
					break;
				}
			}
		}
	}

	/**
	 * Collect all listeners of this node and all listeners of nodes in the
	 * subtree where this node is root
	 * 
	 * @param node
	 * @param listenlist
	 * @return
	 */
	private static ArrayList<ListenerObject> collectAllListenersInSubtree(
			ListenerTreeNode node, ArrayList<ListenerObject> listenerlist) {
		listenerlist.addAll(node.getListeners());
		for (ListenerTreeNode child : node.getChildren())
			collectAllListenersInSubtree(child, listenerlist);
		return listenerlist;
	}

	public static boolean removeListener(ListenerTreeNode root,
			Stack<ASTPathPart> nodePath, IASTChangeListener listener) {
		ListenerTreeNode node = resolvePath(nodePath, root);
		if (node == null)
			return false;
		return node.removeListener(listener);
	}
}