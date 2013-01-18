package org.jastadd.ed.core.service.browsing;

import java.util.Collection;

import org.eclipse.swt.graphics.Image;
import org.jastadd.ed.core.model.node.ITextViewNode;

public interface IBrowsingNode extends ITextViewNode {
	
	public IBrowsingNode browsingDecl();
	public Collection<IBrowsingNode> browsingRefs();
	
	public String browsingLabel();
	public Image browsingImage();
}
