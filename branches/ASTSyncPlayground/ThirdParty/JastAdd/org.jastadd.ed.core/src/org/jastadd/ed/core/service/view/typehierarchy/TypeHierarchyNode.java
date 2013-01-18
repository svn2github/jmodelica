package org.jastadd.ed.core.service.view.typehierarchy;

import java.util.Collection;
import org.eclipse.swt.graphics.Image;
import org.jastadd.ed.core.model.node.ITreeViewNode;
import org.jastadd.ed.core.service.browsing.IBrowsingNode;
import org.jastadd.ed.core.service.view.TreeNode;

public class TypeHierarchyNode extends TreeNode {
	
	// Factory method
	
	public static TypeHierarchyNode convertResult(ITypeHierarchyNode type) {
		TypeHierarchyNode resultNode = createNodeWithChildren(type);	
		// Create parents
		ITypeHierarchyNode current = type;
		ITypeHierarchyNode parent = current.typeHierarchyParent();
		while (parent != null) {
			// Create parent node and connect
			if (parent instanceof IBrowsingNode) {
				TypeHierarchyNode parentNode = createNode(parent);
				parentNode.addChild(resultNode);
				// Let parent node be result node
				resultNode = parentNode;
			}
			// Let parent node be current
			current = parent;
			parent = current.typeHierarchyParent();
			
		}
		
		return resultNode;
	}
	
	private static TypeHierarchyNode createNodeWithChildren(ITypeHierarchyNode type) {
		// Create node and children
		TypeHierarchyNode resultNode = createNode(type);
		Collection<ITypeHierarchyNode> subclasses = type.typeHierarchyChildren();
		for (ITypeHierarchyNode subclass : subclasses) {
			TypeHierarchyNode childNode = createNodeWithChildren(subclass);
			resultNode.addChild(childNode);
		}
		return resultNode;
	}

	private static TypeHierarchyNode createNode(ITypeHierarchyNode typeNode) {
		String label = typeNode.typeHierarchyLabel();
		Image image = typeNode.typeHierarchyImage();
		return new TypeHierarchyNode((ITreeViewNode)typeNode, label, image);
	}
	
	protected TypeHierarchyNode(ITreeViewNode node, String label, Image image) {
		super(node, label, image);
	}
}
