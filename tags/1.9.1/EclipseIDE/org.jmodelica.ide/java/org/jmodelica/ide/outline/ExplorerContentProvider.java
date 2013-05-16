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
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

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
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.StructuredViewer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.ui.progress.UIJob;
import org.jastadd.plugin.compiler.ast.IASTNode;
import org.jastadd.plugin.compiler.ast.IOutlineNode;
import org.jastadd.plugin.registry.ASTRegistry;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.compiler.ModelicaEclipseCompiler;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.Element;
import org.jmodelica.modelica.compiler.LibNode;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class ExplorerContentProvider implements ITreeContentProvider, IResourceChangeListener, IResourceDeltaVisitor {

	private ASTRegistry registry;
	private ModelicaEclipseCompiler cmp;
	private StructuredViewer viewer;
	private Map<IFile,IASTNode> localCompiles;
	private Set<IASTNode> outdatedLocalCompiles;

	public ExplorerContentProvider() {
		registry = org.jastadd.plugin.Activator.getASTRegistry();
		cmp = new ModelicaEclipseCompiler();
		localCompiles = new HashMap<IFile, IASTNode>();
		outdatedLocalCompiles = new HashSet<IASTNode>();
		ResourcesPlugin.getWorkspace().addResourceChangeListener(this, IResourceChangeEvent.POST_CHANGE);
	}

	public Object[] getChildren(Object parentElement) {
		Object[] children = null;
		if (parentElement instanceof IFile) {
			IOutlineNode root = (IOutlineNode) getRoot((IFile) parentElement);
			children = root.outlineChildren().toArray();
//		} else if (parentElement instanceof IProject) {
//			LibrariesList libList = new LibrariesList((IProject) parentElement, viewer);
//			return libList.hasChildren() ? new Object[] { libList } : null;
		} else if (parentElement instanceof ClassDecl) {
			children = getVisible(((ClassDecl) parentElement).classes());
		}
		return OutlineUpdateWorker.addIcons(viewer, children);
	}

	public Object getParent(Object element) {
		if (element instanceof ClassDecl) {
			ASTNode<?> parent = getParentClass((ClassDecl) element);
			if (parent instanceof StoredDefinition) 
				return ((StoredDefinition) parent).getFile();
		} else if (element instanceof LoadedLibraries) {
			return ((LoadedLibraries) element).getParent();
		} 
		return null;
	}

	public boolean hasChildren(Object element) {
		if (element instanceof IFile) {
			IOutlineNode root = (IOutlineNode) getRoot((IFile) element);
			return (root != null) && root.hasVisibleChildren();
		} else if (element instanceof LoadedLibraries) {
			return ((LoadedLibraries) element).hasChildren();
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
		if (ast == null) {
			ast = localCompiles.get(file);
			if (localCompiles.containsKey(file) || outdatedLocalCompiles.contains(ast)) {
				outdatedLocalCompiles.remove(ast);
				new CompileJob(file).schedule();
			}
		} else {
			outdatedLocalCompiles.remove(localCompiles.get(file));
			localCompiles.remove(file);
		}
		return ast;
	}
	
	private ASTNode<?> getParentClass(ASTNode<?> node) {
		while (!(node instanceof ClassDecl || node instanceof StoredDefinition))
			node = node.getParent();
		return node;
	}

	private ASTNode[] getVisible(Iterable<? extends ASTNode> objs) {
		ArrayList<ASTNode> list = new ArrayList<ASTNode>();
		for (ASTNode e : objs) {
			if (e instanceof IOutlineNode && ((IOutlineNode) e).showInContentOutline())
				list.add(e);
		}
		return list.toArray(new ASTNode[list.size()]);
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
			String ext = file.getFileExtension();
			if (ext != null && ext.equals(IDEConstants.MODELICA_FILE_EXT)) {
				IASTNode ast = localCompiles.get(file);
				if (ast != null)
					outdatedLocalCompiles.add(ast);
				new UpdateJob(file).schedule();
			}
			return false;
		}
		return false;
	}

	private final class CompileJob extends Job {
		private IFile file;

		private CompileJob(IFile file) {
			super("Local compilation of " + file);
			setSystem(true);
			setPriority(Job.DECORATE);
			this.file = file;
		}

		protected IStatus run(IProgressMonitor monitor) {
			localCompiles.put(file, cmp.compileFile(file));
			new UpdateJob(file).schedule();
			return Status.OK_STATUS;
		}
	}

	private final class UpdateJob extends UIJob {
		private final IFile file;

		private UpdateJob(IFile file) {
			super("Update Source tree in Project Explorer");
			this.file = file;
			setSystem(true);
			setPriority(Job.SHORT);
		}

		public IStatus runInUIThread(IProgressMonitor monitor) {
			if (viewer != null && !viewer.getControl().isDisposed())
				viewer.refresh(file);
			return Status.OK_STATUS;						
		}
	}

}
