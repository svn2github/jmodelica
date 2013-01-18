package org.jastadd.ed.core.model.node;

import org.eclipse.swt.graphics.Image;

public interface ITreeViewNode extends IASTNode {

    public String treeViewLabel();
    
    public Image treeViewImage();

}
