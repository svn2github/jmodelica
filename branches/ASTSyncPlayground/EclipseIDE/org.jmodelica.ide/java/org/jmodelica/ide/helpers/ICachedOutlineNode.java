package org.jmodelica.ide.helpers;

import java.util.ArrayList;
import java.util.Stack;

import org.eclipse.swt.graphics.Image;
import org.jmodelica.ide.helpers.IOutlineCache;

public interface ICachedOutlineNode {
	Object[] cachedOutlineChildren();

	boolean hasVisibleChildren();

	Object getParent();

	Image getImage();

	String getText();

	void setOutlineChildren(ArrayList<ICachedOutlineNode> children);

	boolean childrenAlreadyCached();

	IOutlineCache getCache();

	void setCache(IOutlineCache cache);

	void setParent(ICachedOutlineNode parent);

	Stack<String> getASTPath();

}
