package org.jastadd.ed.core.service.view;

import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.Viewer;
import org.jastadd.ed.core.service.view.typehierarchy.TypeHierarchyNode;

public class TreeViewContentProvider implements ITreeContentProvider {


	private Object[] fContent = null;

	public Object[] getChildren(Object parentElement) {
		if(parentElement instanceof TreeNode) { 
			return ((TreeNode)parentElement).getChildren().toArray();
		} 
		return new Object[] {};
	}

	public void clear() {
		fContent = null;
	}

	public Object getParent(Object element) {
		if(element instanceof TreeNode) {
			return ((TreeNode)element).getParent();
		}
		return null;
	}

	public boolean hasChildren(Object element) {
		if(element instanceof TreeNode) {
			return !((TreeNode)element).getChildren().isEmpty();
		} else if (element instanceof TreeNode.Wrapper) 
			return true;
		return false;
	}

	public Object[] getElements(Object inputElement) {
		if (inputElement instanceof TreeNode.Wrapper) {
			return new Object[] {((TreeNode.Wrapper)inputElement).getNode()};
		}
		if(inputElement instanceof TreeNode) { 
			return ((TreeNode)inputElement).getChildren().toArray();
		} 
		return new Object[]{};
	}

	public void dispose() {
		// TODO Do something here
	}

	public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {
		fContent = new Object[] {newInput};
	}

	public void elementsChanged(Object[] objects) {
		fContent = objects;
	}
}
