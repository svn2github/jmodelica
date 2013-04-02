package org.jmodelica.ide.outline;

import org.eclipse.swt.graphics.Image;

public interface IOutlineAware {

	public Object[] getElements();

	public Object[] getChildren();

	public boolean hasChildren();

	public Object getParent();

	public Image getImage();

	public String getText();

}
