package org.jmodelica.ide.outline.cache;

import java.util.ArrayList;
import java.util.Stack;

import org.eclipse.swt.graphics.Image;

public interface ICachedOutlineNode {
	Object[] cachedOutlineChildren();

	boolean hasVisibleChildren();

	Object getParent();

	Image getImage();

	String getText();

	void setOutlineChildren(ArrayList<ICachedOutlineNode> children);

	boolean childrenAlreadyCached();

	AbstractOutlineCache getCache();

	void setCache(AbstractOutlineCache cache);

	void setParent(ICachedOutlineNode parent);

	Stack<String> getASTPath();

}
