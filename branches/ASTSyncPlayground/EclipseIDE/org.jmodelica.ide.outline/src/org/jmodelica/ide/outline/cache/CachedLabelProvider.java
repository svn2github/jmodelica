package org.jmodelica.ide.outline.cache;

import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.swt.graphics.Image;
import org.jastadd.ed.core.model.node.ICachedOutlineNode;

public class CachedLabelProvider extends LabelProvider {

	@Override
	public Image getImage(Object element) {
		if (element instanceof ICachedOutlineNode) {
			return ((ICachedOutlineNode) element).getImage();
		}
		return null;
	}

	@Override
	public String getText(Object element) {
		if (element instanceof ICachedOutlineNode) {
			return ((ICachedOutlineNode) element).getText();
		}
		return null;
	}
}