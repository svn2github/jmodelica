package org.jastadd.ed.core.service.view;

import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.swt.graphics.Image;

public class TreeViewLabelProvider extends LabelProvider {

	@Override
	public Image getImage(Object element) {
		if (element instanceof TreeNode) {
			return ((TreeNode)element).getImage(); 
		}
		return null;
	}

	@Override
	public String getText(Object element) {
		if (element instanceof TreeNode) {
			return ((TreeNode)element).getLabel(); 
		}
		return null;
	}

}
