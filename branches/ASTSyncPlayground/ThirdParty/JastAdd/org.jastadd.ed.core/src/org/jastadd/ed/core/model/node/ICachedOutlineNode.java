package org.jastadd.ed.core.model.node;

import java.util.ArrayList;
import java.util.Stack;

import org.eclipse.swt.graphics.Image;
import org.jastadd.ed.core.model.IASTPathPart;
import org.jastadd.ed.core.model.IOutlineCache;

public interface ICachedOutlineNode {

	/**
	 * The cached children of this node.
	 * 
	 * @return
	 */
	Object[] cachedOutlineChildren();

	boolean hasVisibleChildren();

	Object getParent();

	/**
	 * For outline content providers
	 * 
	 * @return
	 */
	Image getImage();

	/**
	 * For outline content providers
	 * 
	 * @return
	 */
	String getText();

	/**
	 * Set the children of this node
	 * 
	 * @param children
	 */
	void setOutlineChildren(ArrayList<ICachedOutlineNode> children);

	/**
	 * Have the children of this node already been cached
	 * 
	 * @return
	 */
	boolean childrenAlreadyCached();

	IOutlineCache getCache();

	void setCache(IOutlineCache cache);

	void setParent(ICachedOutlineNode parent);

	/**
	 * The AST resource path identifying this node
	 * 
	 * @return
	 */
	Stack<IASTPathPart> getASTPath();
}