package org.jmodelica.ide.outline.cache;

import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.StructuredViewer;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.Viewer;
import org.jmodelica.ide.helpers.ICachedOutlineNode;
import org.jmodelica.ide.outline.OutlineUpdateWorker;

public class CachedContentProvider implements ITreeContentProvider {

	private TreeViewer viewer;

	public Object[] getChildren(Object element) {
			if (element instanceof ICachedOutlineNode) {
				ICachedOutlineNode node = (ICachedOutlineNode)element;
				if (node.childrenAlreadyCached()) {
					return node.cachedOutlineChildren();
				} else {
					OutlineUpdateWorker.addChildren(viewer, node);
				}
			}
			return null;
		}

	public Object getParent(Object element) {
		if (element instanceof ICachedOutlineNode) {
			//System.out.println("CachedContentProvider: getParent() node:"
			//		+ ((ICachedOutlineNode) element).getText());
			return ((ICachedOutlineNode) element).getParent();
		}
		return null;
	}

	public boolean hasChildren(Object element) {
		if (element instanceof ICachedOutlineNode) {
			//System.out.println("CachedContentProvider: hasChildren() node:"
			//		+ ((ICachedOutlineNode) element).getText());
			return ((ICachedOutlineNode) element).hasVisibleChildren();
		}
		return false;
	}

	public Object[] getElements(Object element) {
		return getChildren(element);
	}

	public void dispose() {
		//TODO
	}

	public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {
		if (viewer instanceof StructuredViewer)
			this.viewer = (TreeViewer) viewer;
	}
}
