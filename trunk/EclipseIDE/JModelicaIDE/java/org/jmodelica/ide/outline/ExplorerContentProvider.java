/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package org.jmodelica.ide.outline;

import java.util.ArrayList;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceChangeEvent;
import org.eclipse.core.resources.IResourceChangeListener;
import org.eclipse.core.resources.IResourceDelta;
import org.eclipse.core.resources.IResourceDeltaVisitor;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.StructuredViewer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.ui.progress.UIJob;
import org.jastadd.plugin.compiler.ast.IASTNode;
import org.jastadd.plugin.compiler.ast.IOutlineNode;
import org.jastadd.plugin.registry.ASTRegistry;
import org.jastadd.plugin.registry.IASTRegistryListener;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.ModelicaCompiler;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.Element;
import org.jmodelica.modelica.compiler.LibNode;
import org.jmodelica.modelica.compiler.List;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class ExplorerContentProvider implements ITreeContentProvider, IResourceChangeListener, IResourceDeltaVisitor {

	private ASTRegistry registry;
	private ModelicaCompiler cmp;
	private StructuredViewer viewer;

	public ExplorerContentProvider() {
		registry = org.jastadd.plugin.Activator.getASTRegistry();
		cmp = new ModelicaCompiler();
		ResourcesPlugin.getWorkspace().addResourceChangeListener(this, IResourceChangeEvent.POST_CHANGE);
	}

	public Object[] getChildren(Object parentElement) {
		if (parentElement instanceof IFile) {
			parentElement = getRoot((IFile) parentElement);
			return getClassesFromSD((ASTNode<?>) parentElement);
		} 
		if (parentElement instanceof IProject) {
			LibrariesList libList = new LibrariesList((IProject) parentElement);
			return libList.hasChildren() ? new Object[] { libList } : null;
		} else if (parentElement instanceof LibrariesList) {
			return ((LibrariesList) parentElement).getChildren();
		} else if (parentElement instanceof LibNode) {
			return getClassesFromSD(((LibNode) parentElement).getStoredDefinition());
		} else if (parentElement instanceof ClassDecl) {
			return getVisible(((ClassDecl) parentElement).classes());
		}
		return null;
	}

	public Object getParent(Object element) {
		if (element instanceof ClassDecl) {
			ASTNode<?> parent = getParentClass((ClassDecl) element);
			if (parent instanceof StoredDefinition) {
				if (parent.getParent() instanceof LibNode)
					return parent.getParent();
				return ((StoredDefinition) parent).getFile();
			}
		} else if (element instanceof LibNode) {
			return ((LibNode) element).getLibrariesList();
		} else if (element instanceof LibrariesList) {
			return ((LibrariesList) element).getParent();
		} 
		return null;
	}

	public boolean hasChildren(Object element) {
		if (element instanceof IFile) {
			return true;
		} else if (element instanceof LibrariesList) {
			return ((LibrariesList) element).hasChildren();
		} else if (element instanceof LibNode) {
			return hasSDChildren(((LibNode) element).getStoredDefinition());
		} else if (element instanceof ClassDecl) {
			return ((ClassDecl) element).hasClasses();
		}
		return false;
	}

	private IASTNode getRoot(IFile file) {
		IProject project = file.getProject();
		String path = file.getRawLocation().toOSString();
		IASTNode ast = registry.lookupAST(path, project);
		// TODO: Need to save in registry even if we have to build ourselves
		return ast == null ? cmp.compileFile(file, path) : ast;
	}
	
	private ASTNode<?> getParentClass(ASTNode<?> node) {
		while (!(node instanceof ClassDecl || node instanceof StoredDefinition))
			node = node.getParent();
		return node;
	}

	private Object[] getClassesFromSD(ASTNode<?> node) {
		if (!(node instanceof StoredDefinition))
			return null;
		StoredDefinition sd = (StoredDefinition) node;
		return getVisible(sd.getElements());
	}

	private Object[] getVisible(Iterable<?> objs) {
		ArrayList<Object> list = new ArrayList<Object>();
		for (Object e : objs) {
			if (e instanceof IOutlineNode && ((IOutlineNode) e).showInContentOutline())
				list.add(e);
		}
		return list.toArray();
	}

	private boolean hasSDChildren(ASTNode<?> node) {
		if (!(node instanceof StoredDefinition))
			return false;
		for (Element e : ((StoredDefinition) node).getElements())
			if (e.showInContentOutline())
				return true;
		return false;
	}

	public Object[] getElements(Object inputElement) {
		return null;
	}

	public void dispose() {
	}

	public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {
		this.viewer = (StructuredViewer) viewer;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.core.resources.IResourceChangeListener#resourceChanged(org.eclipse.core.resources.IResourceChangeEvent)
	 */
	public void resourceChanged(IResourceChangeEvent event) {
		IResourceDelta delta = event.getDelta();
		try {
			delta.accept(this);
		} catch (CoreException e) { 
			e.printStackTrace();
		} 
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.core.resources.IResourceDeltaVisitor#visit(org.eclipse.core.resources.IResourceDelta)
	 */
	public boolean visit(IResourceDelta delta) {
		IResource source = delta.getResource();
		switch (source.getType()) {
		case IResource.ROOT:
		case IResource.PROJECT:
		case IResource.FOLDER:
			return true;
		case IResource.FILE:
			final IFile file = (IFile) source;
			if (file.getFileExtension().equals(IDEConstants.FILE_EXTENSION)) {
				new UIJob("Update Source tree in Project Explorer") {
					public IStatus runInUIThread(IProgressMonitor monitor) {
						if (viewer != null && !viewer.getControl().isDisposed())
							viewer.refresh(file);
						return Status.OK_STATUS;						
					}
				}.schedule();
			}
			return false;
		}
		return false;
	} 
	
	public class LibrariesList implements IASTRegistryListener {
		
		private LibNode[] libraries;
		private IProject project;
		
		public LibrariesList(IProject project) {
			this.project = project;
			readLibraries();
			registry.addListener(this, project, null);
		}

		private void readLibraries() {
			IASTNode ast = registry.lookupAST(null, project);
			if (ast instanceof SourceRoot) {
				List<LibNode> libNodes = ((SourceRoot) ast).getProgram().getLibNodes();
				int n = libNodes.getNumChild();
				if (n > 0) {
					libraries = new LibNode[n];
					for (int i = 0; i < n; i++) {
						libraries[i] = libNodes.getChild(i);
						libraries[i].setLibrariesList(this);
					}
				}
			}
		}
		
		public LibNode[] getChildren() {
			return libraries;
		}
		
		public boolean hasChildren() {
			return libraries != null;
		}
		
		public IProject getParent() {
			return project;
		}
		
		@Override
		public String toString() {
			return "Loaded Libraries";
		}

		public void childASTChanged(IProject project, String key) {
		}

		public void projectASTChanged(IProject project) {
			boolean hadChildren = hasChildren();
			readLibraries();
			boolean updProj = hadChildren != hasChildren();
			viewer.refresh(updProj ? project : this);
		}
	}
}
