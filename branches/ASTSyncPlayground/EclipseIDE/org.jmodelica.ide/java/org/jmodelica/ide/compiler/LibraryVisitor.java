package org.jmodelica.ide.compiler;

import java.util.ArrayList;

import org.jastadd.ed.core.model.ASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jastadd.ed.core.model.node.IASTNode;

public class LibraryVisitor {
	/**
	 * Update library and remove node and path
	 * 
	 * @param root
	 * @param nodePath
	 */
	public void handleChangedNode(int astChangeEventType,LibraryNode root, ArrayList<String> nodePath, IASTNode changedInstNode) {
		ArrayList<IASTChangeListener> affectedListeners = new ArrayList<IASTChangeListener>();
		getAllAffectedListeners(root, nodePath, affectedListeners);
		removeLibraryPath(root, nodePath);
		System.out
				.println("LibraryVisitor: Found nbr affected listeners of path: "
						+ affectedListeners.size());
		for (IASTChangeListener listener : affectedListeners) {
			listener.astChanged(new ASTChangeEvent(astChangeEventType,
					ASTChangeEvent.FILE_LEVEL, changedInstNode, nodePath, null));
		}//TODO update astchangeevent now sending instnode
	}

	/**
	 * Remove the end node corresponding to the given path.
	 * 
	 * @param root
	 * @param nodePath
	 */
	private void removeLibraryPath(LibraryNode root, ArrayList<String> nodePath) {
		// TODO remove path from library
	}

	/**
	 * If nodePath is not this node, continue downwards in tree. When correct
	 * node is found, register listener.
	 * 
	 * @param node
	 * @param nodePath
	 * @param listener
	 */
	public void addListener(LibraryNode node, ArrayList<String> nodePath,
			IASTChangeListener listener) {
		if (nodePath.size() == 0) {
			node.addListener(listener);
			System.out
					.println("LibraryVisitorAdded listener to a library node...");
			for (int i = 0; i < nodePath.size(); i++) {
				System.out.println(nodePath.get(i) + "/");
			}
		} else if (nodePath.size() > 0) {
			boolean found = false;
			for (LibraryNode child : node.getChildren()) { // Check if any child
															// is along
				// path.
				if (nodePath.get(0).equals(child.getId())) {
					found = true;
					nodePath.remove(0);
					addListener(child, nodePath, listener);
					break;
				}
			}
			if (!found) { // No previous listeners along this path, create a new
							// child node and move on to that node.
				LibraryNode newNode = new LibraryNode(nodePath.remove(0));
				node.addChild(newNode);
				addListener(newNode, nodePath, listener);
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
			ArrayList<String> nodePath,
			ArrayList<IASTChangeListener> listenerlist) {
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
			ArrayList<String> nodePath,
			ArrayList<IASTChangeListener> listenerlist) {
		listenerlist.addAll(node.getListeners());
		String soughtNodeId = nodePath.get(0);
		for (LibraryNode child : node.getChildren()) {
			if (child.getId().equals(soughtNodeId)) {
				nodePath.remove(0);
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
	private ArrayList<IASTChangeListener> collectAllListenersInSubtree(
			LibraryNode node, ArrayList<IASTChangeListener> listenerlist) {
		listenerlist.addAll(node.getListeners());
		for (LibraryNode child : node.getChildren())
			collectAllListenersInSubtree(child, listenerlist);
		return listenerlist;
	}
}
