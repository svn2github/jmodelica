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

import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceChangeEvent;
import org.eclipse.core.resources.IResourceChangeListener;
import org.eclipse.core.resources.IResourceDelta;
import org.eclipse.core.resources.IResourceDeltaVisitor;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.Viewer;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.helpers.ICachedOutlineNode;
import org.jmodelica.ide.outline.OutlineUpdateWorker.ChildrenTask;
import org.jmodelica.ide.outline.cache.CachedContentProvider;
import org.jmodelica.ide.outline.cache.EventCachedFileChildren;
import org.jmodelica.ide.sync.ListenerObject;
import org.jmodelica.ide.sync.ModelicaASTRegistry;

public class ExplorerContentProvider extends CachedContentProvider implements
		IResourceChangeListener, IResourceDeltaVisitor, IASTChangeListener {

	private Map<IFile, ICachedOutlineNode> astCacheMap;
	private ExplorerOutlineCache cache;

	public ExplorerContentProvider() {
		cache = new ExplorerOutlineCache(this);
		astCacheMap = new HashMap<IFile, ICachedOutlineNode>();
		ResourcesPlugin.getWorkspace().addResourceChangeListener(this,
				IResourceChangeEvent.POST_CHANGE);
	}

	public Object[] getChildren(Object parentElement) {
		Object[] children = null;
		if (parentElement instanceof IFile) {
			IFile file = (IFile) parentElement;
			if (!astCacheMap.containsKey(file)) {
				cache.fetchFileChildren(file);
			} else {
				children = super.getChildren(astCacheMap.get(file));
			}
		} else {
			children = super.getChildren(parentElement);
		}
		return children;
	}

	public Object getParent(Object element) {
		if (element instanceof ICachedOutlineNode) {
			Object parent = super.getParent(element);
			if (parent == null) {
				ICachedOutlineNode sought = (ICachedOutlineNode) element;
				for (Entry<IFile, ICachedOutlineNode> entry : astCacheMap
						.entrySet())
					if (entry.getValue().equals(sought))
						return entry.getKey();
			}
		}
		return null;
	}

	public boolean hasChildren(Object element) {
		if (element instanceof IFile) {
			IFile file = (IFile) element;
			if (!astCacheMap.containsKey(file)) {
				ModelicaASTRegistry.getInstance().addListener(file, null,
						new ListenerObject(cache, OUTLINE_LISTENER));
				cache.fetchFileChildren(file);
				return true;
			}
			ICachedOutlineNode root = astCacheMap.get(file);
			return (root != null && root.hasVisibleChildren());
		}
		return super.hasChildren(element);
	}

	public Object[] getElements(Object inputElement) {
		return null;
	}

	public void dispose() {
	}

	public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {
		this.viewer = (TreeViewer) viewer;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * org.eclipse.core.resources.IResourceChangeListener#resourceChanged(org
	 * .eclipse.core.resources.IResourceChangeEvent)
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
	 * @see
	 * org.eclipse.core.resources.IResourceDeltaVisitor#visit(org.eclipse.core
	 * .resources.IResourceDelta)
	 */
	public boolean visit(IResourceDelta delta) {
		IResource source = delta.getResource();
		switch (source.getType()) {
		case IResource.ROOT:
		case IResource.PROJECT:
		case IResource.FOLDER:
			return true;
		case IResource.FILE:
			if (delta.getKind() != IResourceDelta.CHANGED) {
				final IFile file = (IFile) source;
				String ext = file.getFileExtension();
				if (ext != null && ext.equals(IDEConstants.MODELICA_FILE_EXT)) {
					cache.fetchFileChildren(file);
				}
				if (delta.getKind() == IResourceDelta.ADDED)
					ModelicaASTRegistry.getInstance().addListener(file, null,
							new ListenerObject(cache, OUTLINE_LISTENER));
				if (delta.getKind() == IResourceDelta.REMOVED)
					ModelicaASTRegistry.getInstance().removeListener(file,
							null, cache);
			}
			return false;
		}
		return false;
	}

	@Override
	public void astChanged(IASTChangeEvent e) {
		if (e instanceof EventCachedFileChildren) {
			EventCachedFileChildren event = (EventCachedFileChildren) e;
			astCacheMap.put(event.getFile(), event.getRoot());
			ChildrenTask task = new ChildrenTask(viewer, event.getFile());
			task.expandDepth = 0;
			OutlineUpdateWorker.addChildrenTask(task);
		}
	}
}