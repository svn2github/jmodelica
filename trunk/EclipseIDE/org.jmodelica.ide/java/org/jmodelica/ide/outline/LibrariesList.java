package org.jmodelica.ide.outline;

import java.util.ArrayList;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.jface.viewers.ILabelProvider;
import org.eclipse.jface.viewers.ILabelProviderListener;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.StructuredViewer;
import org.eclipse.swt.graphics.Image;
import org.jastadd.plugin.compiler.ast.IASTNode;
import org.jastadd.plugin.registry.ASTRegistry;
import org.jastadd.plugin.registry.IASTRegistryListener;
import org.jmodelica.ide.ui.ImageLoader;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.LibNode;
import org.jmodelica.modelica.compiler.List;
import org.jmodelica.modelica.compiler.SourceRoot;

public class LibrariesList implements IOutlineAware {

	protected ASTNode[] libraries;
	protected ASTNode[] filtered;
	protected boolean loaded;
	protected SourceRoot parent;
	
	public LibrariesList(SourceRoot root) {
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
		
	    ArrayList<ASTNode> libList = new ArrayList<ASTNode>();
	    ArrayList<ASTNode> filtList = new ArrayList<ASTNode>();
	    for (LibNode ln : parent.getProgram().getLibNodes()) {
	    	for (Object o : ln.getStoredDefinition().outlineChildren()) {
	    		ASTNode n = (ASTNode) o;
	    		(filter(n) ? filtList : libList).add(n);
	    	}
	    }
	    for (ASTNode n : libList)
	    	n.setLibrariesList(this);
	    libraries = libList.isEmpty() ? null : libList.toArray(new ASTNode[libList.size()]);
	    filtered = filtList.isEmpty() ? null : filtList.toArray(new ASTNode[filtList.size()]);

		loaded = true;
	}
	
	protected boolean filter(ASTNode node) {
		if (node instanceof ClassDecl) {
			ClassDecl cd = (ClassDecl) node;
			if (cd.name().equals("Modelica"))
				return true;
			IFile file = cd.getDefinition().getFile();
			return file != null && file.getProject() == parent.getProject();
		}
		return false;
	}
	
	public ASTNode[] getFiltered() {
		readLibraries();
		return filtered;
	}
	
	public boolean hasFiltered() {
		readLibraries();
		return filtered != null;
	}
	
	public ASTNode[] getChildren() {
		readLibraries();
		return libraries;
	}
	
	public boolean hasChildren() {
		readLibraries();
		return libraries != null;
	}

	public Object getParent() {
		return parent;
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
}