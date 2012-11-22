package org.jmodelica.ide.outline;

import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.Viewer;

public class OutlineAwareContentProvider implements ITreeContentProvider {

	private ITreeContentProvider parent;
	
	public OutlineAwareContentProvider() {
		parent = null;
	}

	public OutlineAwareContentProvider(ITreeContentProvider parent) {
		this.parent = parent;
	}

	public void dispose() {
	}

	public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {
	}

	public Object[] getElements(Object inputElement) {
		if (inputElement instanceof IOutlineAware)
			return ((IOutlineAware) inputElement).getElements();
		else if (parent != null)
			return parent.getElements(inputElement);
		else
			return null;
	}

	public Object[] getChildren(Object parentElement) {
		if (parentElement instanceof IOutlineAware)
			return ((IOutlineAware) parentElement).getChildren();
		else if (parent != null)
			return parent.getChildren(parentElement);
		else
			return null;
	}

	public Object getParent(Object element) {
		if (element instanceof IOutlineAware)
			return ((IOutlineAware) element).getParent();
		else if (parent != null)
			return parent.getParent(element);
		else
			return null;
	}

	public boolean hasChildren(Object element) {
		if (element instanceof IOutlineAware)
			return ((IOutlineAware) element).hasChildren();
		else if (parent != null)
			return parent.hasChildren(element);
		else
			return false;
	}

}
