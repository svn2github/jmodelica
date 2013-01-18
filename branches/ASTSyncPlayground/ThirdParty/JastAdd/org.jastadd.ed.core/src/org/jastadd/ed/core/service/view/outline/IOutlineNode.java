package org.jastadd.ed.core.service.view.outline;

import java.util.ArrayList;
import org.eclipse.swt.graphics.Image;
import org.jastadd.ed.core.model.node.ITextViewNode;

public interface IOutlineNode extends ITextViewNode {
	
	// Structure
	
	public ArrayList<IOutlineNode> outlineChildren();
    
    public String outlineLabel();
    
    public Image outlineImage();
    
    // Selection
    
    public boolean showInOutline();
    
}
