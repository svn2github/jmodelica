package org.jastadd.ed.core.service.view;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import org.eclipse.swt.graphics.Image;
import org.jastadd.ed.core.model.node.ITreeViewNode;


public abstract class TreeNode implements ITreeNode {
	
	public static class Wrapper {
		private TreeNode fNode;
		public Wrapper(TreeNode node) {
			fNode = node;
		}
		public TreeNode getNode() {
			return fNode;
		}
	}
	
	protected List<ITreeNode> fChildren;
	protected TreeNode fParent;
	protected ITreeViewNode fTypeNode;

	protected String fLabel;
	protected Image fImage;


	protected TreeNode(ITreeViewNode typeNode, String label, Image image) {
		fChildren = new ArrayList<ITreeNode>();
		fTypeNode = typeNode;
		fLabel = label;
		fImage = image;
	}

	public boolean hasChildren() {
		return !fChildren.isEmpty();
	}

	public Collection<ITreeNode> getChildren() {
		return fChildren;
	}

	public TreeNode addChild(TreeNode node) {
		fChildren.add(node);
		node.fParent = this;
		return this;
	}

	public TreeNode getParent() {
		return fParent;
	}
	public void setParent(TreeNode node) {
		fParent = node;
	}

	public ITreeViewNode getNode() {
		return fTypeNode;
	}

	public String getLabel() {
		return fLabel;
	}

	public Image getImage() {
		return fImage;
	}
}
