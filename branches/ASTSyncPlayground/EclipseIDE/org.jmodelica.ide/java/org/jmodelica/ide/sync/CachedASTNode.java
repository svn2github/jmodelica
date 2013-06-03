package org.jmodelica.ide.sync;

import java.util.ArrayList;
import java.util.Stack;

import org.eclipse.swt.graphics.Image;
import org.jastadd.ed.core.model.IASTPathPart;
import org.jastadd.ed.core.model.IOutlineCache;
import org.jastadd.ed.core.model.node.ICachedOutlineNode;
import org.jmodelica.icons.Icon;
import org.jmodelica.icons.drawing.AWTIconDrawer;
import org.jmodelica.ide.helpers.ImageLoader;
import org.jmodelica.ide.helpers.SWTIconDrawer;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.BaseNode;

public class CachedASTNode implements ICachedOutlineNode {
	protected Stack<IASTPathPart> myASTPath;
	private ArrayList<ICachedOutlineNode> outlineChildren = new ArrayList<ICachedOutlineNode>();
	protected Icon icon;
	private Image image;
	private String text;
	private Object parent;
	private boolean hasVisibleChildren;
	private boolean childrenAlreadyCached = false;
	private String containingFileName;
	private int selectionNodeOffset;
	private int outlineCategory;
	private int declareOrder;
	private boolean isInLibrary;
	private IOutlineCache cache;
	private int selectionNodeLength;

	public CachedASTNode(ASTNode<?> node, Object parent, IOutlineCache cache) {
		this.cache = cache;
		if (node instanceof BaseNode)
			this.icon = ((BaseNode) node).icon();
		myASTPath = ModelicaASTRegistry.getInstance().createPath(node);
		hasVisibleChildren = node.hasVisibleChildren();
		containingFileName = node.containingFileName();
		text = node.contentOutlineLabel();
		selectionNodeOffset = node.getSelectionNode().offset();
		selectionNodeLength = node.getSelectionNode().length();
		outlineCategory = node.outlineCategory();
		declareOrder = node.declareOrder();
		isInLibrary = node.isInLibrary();
		this.parent = parent;
	}

	public Object getParent() {
		return parent;
	}

	public Stack<IASTPathPart> getASTPath() {
		return myASTPath;
	}

	public String getText() {
		return text;
	}

	public boolean childrenAlreadyCached() {
		return childrenAlreadyCached;
	}

	/**
	 * Check hasOutlineChildrenBeenCached() before this.
	 * 
	 * @return
	 */
	public Object[] cachedOutlineChildren() {
		return outlineChildren.toArray();
	}

	public boolean hasVisibleChildren() {
		return hasVisibleChildren;
	}

	public Image getImage() {
		if (image == null)
			return renderIcon(icon);
		return image;
	}

	private Image renderIcon(Icon icon) {
		if (icon.isEmpty())
			image = defaultIcon();
		else
			image = SWTIconDrawer.convertImage(new AWTIconDrawer(icon)
					.getImage());
		return image;
	}

	private Image defaultIcon() {
		return ImageLoader.getFrequentImage(ImageLoader.GENERIC_CLASS_IMAGE);
	}

	public String containingFileName() {
		return containingFileName;
	}

	public int getSelectionNodeOffset() {
		return selectionNodeOffset;
	}

	public int getSelectionNodeLength() {
		return selectionNodeLength;
	}

	public int outlineCategory() {
		return outlineCategory;
	}

	public int declareOrder() {
		return declareOrder;
	}

	public boolean isInLibrary() {
		return isInLibrary;
	}

	public void setOutlineChildren(ArrayList<ICachedOutlineNode> children) {
		outlineChildren = children;
		childrenAlreadyCached = true;
	}

	@Override
	public IOutlineCache getCache() {
		return cache;
	}

	@Override
	public void setCache(IOutlineCache cache) {
		this.cache = cache;
	}

	@Override
	public void setParent(ICachedOutlineNode parent) {
		this.parent = parent;
	}
}