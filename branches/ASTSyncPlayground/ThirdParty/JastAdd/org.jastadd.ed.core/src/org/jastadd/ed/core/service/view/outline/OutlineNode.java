package org.jastadd.ed.core.service.view.outline;

import java.util.Collection;
import org.eclipse.swt.graphics.Image;
import org.jastadd.ed.core.model.node.ITreeViewNode;
import org.jastadd.ed.core.service.view.TreeNode;

public class OutlineNode extends TreeNode {
	
	// Factory method
	
	public static OutlineNode convertResult(IOutlineNode type) {
		return createNodeWithChildren(type);			
	}
	
	private static OutlineNode createNodeWithChildren(IOutlineNode type) {
		// Create node and children
		OutlineNode resultNode = createNode(type);
		Collection<IOutlineNode> children = type.outlineChildren();
		for (IOutlineNode child : children) {
			OutlineNode childNode = createNodeWithChildren(child);
			resultNode.addChild(childNode);
		}
		return resultNode;
	}

	private static OutlineNode createNode(IOutlineNode typeNode) {
		String label = typeNode.outlineLabel();
		Image image = typeNode.outlineImage();
		return new OutlineNode((ITreeViewNode)typeNode, label, image);
	}
	
	protected OutlineNode(ITreeViewNode node, String label, Image image) {
		super(node, label, image);
	}
}
