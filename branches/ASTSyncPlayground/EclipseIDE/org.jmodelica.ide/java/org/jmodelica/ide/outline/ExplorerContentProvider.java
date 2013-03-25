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
import org.jmodelica.ide.outline.cache.CachedContentProvider;
import org.jmodelica.ide.outline.cache.EventCachedFileChildren;
import org.jmodelica.ide.outline.cache.ICachedOutlineNode;

//TODO handle file changes comp added etc...
public class ExplorerContentProvider extends CachedContentProvider implements
		IResourceChangeListener, IResourceDeltaVisitor, IASTChangeListener {

	private TreeViewer viewer;
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
			if (!astCacheMap.containsKey((IFile) parentElement)) {
				cache.fetchFileChildren(file, viewer);
			} else {
				children = super.getChildren(astCacheMap
						.get((IFile) parentElement));
			}
		} else {
			children = super.getChildren(parentElement);
		}
		// ICachedOutlineNode root = astCache.get((IFile) parentElement);
		// children = root.outlineChildren().toArray();
		// } else if (parentElement instanceof IProject) {
		// LibrariesList libList = new LibrariesList((IProject)
		// parentElement, viewer);
		// return libList.hasChildren() ? new Object[] { libList } : null;
		// } else if (parentElement instanceof ClassDecl) {
		// children = getVisible(((ClassDecl) parentElement).classes());
		// }
		// return OutlineUpdateWorker.addIcons(viewer, children);
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
			System.out.println(">>>Haschildren file:" + file.getName());
			if (!astCacheMap.containsKey(file)) {
				System.out.println(">>>didnt have file is astmap, fetching children");
				cache.fetchFileChildren(file, viewer);
				return true;
			}
			ICachedOutlineNode root = astCacheMap.get(file);
			boolean hasc = (root != null && root.hasVisibleChildren());
			System.out
					.println(">>>we had file in astmap, haschildren?=" + hasc);
			return hasc;
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
			final IFile file = (IFile) source;
			String ext = file.getFileExtension();
			if (ext != null && ext.equals(IDEConstants.MODELICA_FILE_EXT)) {
				ICachedOutlineNode ast = astCacheMap.get(file);
				if (ast != null)
					cache.fetchFileChildren(file, viewer);
				// new UpdateJob(file).schedule();
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
			OutlineUpdateWorker.addChildrenTask(event.getTask());
		}
	}

}
