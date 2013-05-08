package org.jmodelica.ide.helpers;

import java.util.ArrayList;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.eclipse.swt.graphics.Image;
import org.jmodelica.ide.helpers.IOutlineCache;
import org.jmodelica.ide.sync.ASTPathPart;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.LibNode;
import org.jmodelica.modelica.compiler.SourceRoot;

public class LoadedLibraries implements ICachedOutlineNode {

	protected ASTNode<?>[] libraries;
	protected ASTNode<?>[] filtered;
	protected boolean loaded;
	protected SourceRoot parent;
	private Object[] cachedOutlineChildren;
	private ICachedOutlineNode cachedParent;
	private Stack<ASTPathPart> astPath;
	private IOutlineCache cache;

	public LoadedLibraries(SourceRoot root) {
		parent = root;
		resetLibraries();
	}

	public void resetLibraries() {
		libraries = null;
		loaded = false;
	}

	private void readLibraries() {
		if (loaded)
			return;

		ArrayList<ASTNode<?>> libList = new ArrayList<ASTNode<?>>();
		ArrayList<ASTNode<?>> filtList = new ArrayList<ASTNode<?>>();
		for (LibNode ln : parent.getProgram().getLibNodes()) {
			for (Object o : ln.getStoredDefinition().outlineChildren()) {
				ASTNode<?> n = (ASTNode<?>) o;
				(filter(n) ? filtList : libList).add(n);
			}
		}
		for (ASTNode<?> n : libList)
			n.setLoadedLibraries(this);
		libraries = libList.isEmpty() ? null : libList
				.toArray(new ASTNode[libList.size()]);
		filtered = filtList.isEmpty() ? null : filtList
				.toArray(new ASTNode[filtList.size()]);

		loaded = true;
	}

	public boolean filter(ASTNode<?> node) {
		if (node instanceof ClassDecl) {
			ClassDecl cd = (ClassDecl) node;
			// if (cd.name().equals("Modelica"))
			// return true;
			IFile file = cd.getDefinition().getFile();
			return file != null && file.getProject() == parent.getProject();
		}
		return false;
	}

	public ASTNode<?>[] getFiltered() {
		readLibraries();
		return filtered;
	}

	public boolean hasFiltered() {
		readLibraries();
		return filtered != null;
	}

	public ASTNode<?>[] getChildren() {
		readLibraries();
		return libraries;
	}

	public boolean hasChildren() {
		readLibraries();
		return libraries != null;
	}

	public Object getParent() {
		return cachedParent;
	}

	@Override
	public String toString() {
		return "Loaded Libraries";
	}

	public Image getImage() {
		return ImageLoader.getImage(ImageLoader.LIBRARY_IMAGE);
	}

	public String getText() {
		return toString();
	}

	public Object[] getElements() {
		// Shouldn't be root
		return null;
	}

	public Object[] cachedOutlineChildren() {
		if (cachedOutlineChildren != null && cachedOutlineChildren.length > 0) {
			System.out.println("LIB returned cahedOutlineChildren");
			return cachedOutlineChildren;

		}
		System.out.println("lib returned getchildren");
		return getChildren();
	}

	public boolean hasVisibleChildren() {
		readLibraries();
		return libraries != null;
	}

	@Override
	public void setOutlineChildren(ArrayList<ICachedOutlineNode> children) {
		cachedOutlineChildren = children.toArray();
	}

	public void setParent(ICachedOutlineNode parent) {
		this.cachedParent = parent;
	}

	@Override
	public boolean childrenAlreadyCached() {
		return cachedOutlineChildren != null;
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
	public Stack<ASTPathPart> getASTPath() {
		return astPath;
	}

	public void setASTPath(Stack<ASTPathPart> path) {
		astPath = path;
	}
}