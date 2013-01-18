package org.jastadd.ed.core.service.view;

import java.util.Collection;
import org.eclipse.swt.graphics.Image;
import org.jastadd.ed.core.model.node.ITreeViewNode;

public interface ITreeNode {

	public boolean hasChildren();
	public Collection<ITreeNode> getChildren();
	public ITreeNode addChild(TreeNode node);
	public ITreeNode getParent();
	public ITreeViewNode getNode();
	public String getLabel();
	public Image getImage();

}
