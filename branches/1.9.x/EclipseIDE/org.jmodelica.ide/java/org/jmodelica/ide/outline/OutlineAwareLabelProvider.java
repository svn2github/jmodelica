package org.jmodelica.ide.outline;

import org.eclipse.jface.viewers.ILabelProvider;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.swt.graphics.Image;

public class OutlineAwareLabelProvider extends LabelProvider {

	private ILabelProvider parent;
	
	public OutlineAwareLabelProvider() {
		parent = null;
	}

	public OutlineAwareLabelProvider(ILabelProvider parent) {
		this.parent = parent;
	}

	public Image getImage(Object element) {
		if (element instanceof IOutlineAware)
			return ((IOutlineAware) element).getImage();
		else if (parent != null)
			return parent.getImage(element);
		else
			return super.getImage(element);
	}

	public String getText(Object element) {
		if (element instanceof IOutlineAware)
			return ((IOutlineAware) element).getText();
		else if (parent != null)
			return parent.getText(element);
		else
			return super.getText(element);
	}

}
