package org.jmodelica.ide.compiler;

import java.util.HashMap;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.StoredDefinition;

import com.sun.xml.internal.bind.v2.runtime.reflect.Lister;

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
			IASTChangeListener listener, int listenerType) {

		System.out.println("MODELICAASTREGISTRY: Added listener to file "
				+ file.getName());
		LibraryNode root = listenerTrees.get(file);
		if (root == null) {
			root = new LibraryNode(null);
			listenerTrees.put(file, root);
		}
		Stack<Integer> nodePath = new Stack<Integer>();
		createPath(nodePath, node);
		LibraryVisitor visitor = new LibraryVisitor();
		visitor.addListener(root, nodePath, listener, listenerType);
	}

	public void createPath(Stack<Integer> nodePath, ASTNode<?> node) {
		if (node != null && !(node instanceof StoredDefinition)) {
			ASTNode<?> parent = node.getParent();
			for (int i = 0; i < parent.getNumChild(); i++) {
				if (parent.getChild(i).equals(node)) {
					System.out.println("YEAH, found CHILD creating PATH..."
							+ node.getNodeName());
					nodePath.add(i);
					createPath(nodePath, parent);
				}
			}
		}
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
			ASTNode<?> srcNode, Stack<Integer> nodePath) {
		LibraryVisitor visitor = new LibraryVisitor();
		LibraryNode libroot = listenerTrees.get(file);
		visitor.handleChangedNode(changeType, libroot, nodePath, srcNode);
	}
}
