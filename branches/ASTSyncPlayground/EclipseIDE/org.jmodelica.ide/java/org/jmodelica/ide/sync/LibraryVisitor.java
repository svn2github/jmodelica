package org.jmodelica.ide.sync;

import java.util.ArrayList;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;

public class LibraryVisitor {
	/**
	 * Update library and remove node and path
	 * 
	 * @param root
	 * @param nodePath
	 */
	public void handleChangedNode(IFile file, int astChangeEventType,
			LibraryNode root, Stack<String> nodePath) {
		ArrayList<ListenerObject> affectedListeners = new ArrayList<ListenerObject>();
		getAllAffectedListeners(root, nodePath, affectedListeners);
		System.out
				.println("LibraryVisitor: Found nbr affected listeners of path: "
						+ affectedListeners.size());
		if (astChangeEventType == IASTChangeEvent.POST_REMOVE) {
			removeLibraryPath(root, nodePath);
		} // TODO rename
		for (ListenerObject obj : affectedListeners) {
			obj.doUpdate(file, astChangeEventType, nodePath);
		}
	}

	/**
	 * Remove the end node corresponding to the given path.
	 * 
	 * @param root
	 * @param nodePath
	 */
	private void removeLibraryPath(LibraryNode root, Stack<String> nodePath) {
		int pathSize = nodePath.size();
		if (pathSize > 0) {
			while (nodePath.size() > 0) {
				String sought = nodePath.pop();
				for (LibraryNode node : root.getChildren()) {
					if (node.getId().equals(sought)) {
						if (nodePath.size() == 0) {
							root.getChildren().remove(node);
							node = null;
							break;
						} else {
							root = node;
						}
					}
				}
			}
		} else {
			root = null;
		}
	}

	/**
	 * If nodePath is not this node, continue downwards in tree. When correct
	 * node is found, register listener.
	 * 
	 * @param node
	 * @param nodePath
	 * @param listener
	 * @param astChangeListenerType
	 */
	public void addListener(LibraryNode node, Stack<String> nodePath,
			ListenerObject listObj) {
		if (nodePath == null || nodePath.size() == 0) {
			node.addListener(listObj);
		} else if (nodePath.size() > 0) {
			String id = nodePath.pop();
			boolean found = false;
			for (LibraryNode child : node.getChildren()) {
				// Check if any child is along path.
				if (id.equals(child.getId())) {
					found = true;
					addListener(child, nodePath, listObj);
					break;
				}
			}
			if (!found) { // No previous listeners along this path, create a new
							// child node and move on to that node.
				LibraryNode newNode = new LibraryNode(id);
				node.addChild(newNode);
				addListener(newNode, nodePath, listObj);
			}
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
	public void getAllAffectedListeners(LibraryNode node,
			Stack<String> nodePath, ArrayList<ListenerObject> listenerlist) {
		if (nodePath.size() > 0) { // Collect listeners of nodes along path
			collectVisitorsAndMoveOn(node, nodePath, listenerlist);
		} else if (nodePath.size() == 0) { // Collect listeners in subtree under
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
	private void collectVisitorsAndMoveOn(LibraryNode node,
			Stack<String> nodePath, ArrayList<ListenerObject> listenerlist) {
		listenerlist.addAll(node.getListeners());
		String soughtNodeId = nodePath.pop();
		for (LibraryNode child : node.getChildren()) {
			if (child.getId().equals(soughtNodeId)) {
				getAllAffectedListeners(child, nodePath, listenerlist);
				break;
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
	private ArrayList<ListenerObject> collectAllListenersInSubtree(
			LibraryNode node, ArrayList<ListenerObject> listenerlist) {
		listenerlist.addAll(node.getListeners());
		for (LibraryNode child : node.getChildren())
			collectAllListenersInSubtree(child, listenerlist);
		return listenerlist;
	}

	public boolean removeListener(LibraryNode root, Stack<String> nodePath,
			IASTChangeListener listener) {
		if (!nodePath.isEmpty()) {
			String soughtNodeId = nodePath.pop();
			for (LibraryNode child : root.getChildren()) {
				if (child.getId().equals(soughtNodeId)) {
					if (nodePath.size() == 0) {
						if (child.removeListener(listener))
							return true;
					} else {
						return removeListener(child, nodePath, listener);
					}
					break;
				}
			}
		} else {
			return root.removeListener(listener);
		}
		return false;
	}
}
