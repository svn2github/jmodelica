package org.jastadd.ed.core.model.node;

import java.util.ArrayList;

public interface IOutlineNode {
	
    public boolean showInContentOutline();
    
    public String contentOutlineLabel();
    
    public org.eclipse.swt.graphics.Image contentOutlineImage();

    public boolean hasVisibleChildren();

    @SuppressWarnings("unchecked")
	public ArrayList outlineChildren();
}
