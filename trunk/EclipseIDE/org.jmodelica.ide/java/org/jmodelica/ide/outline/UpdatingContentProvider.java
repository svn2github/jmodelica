package org.jmodelica.ide.outline;

import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.StructuredViewer;
import org.eclipse.jface.viewers.Viewer;
import org.jmodelica.modelica.compiler.ASTNode;

public class UpdatingContentProvider implements ITreeContentProvider {
	
	private ITreeContentProvider parent;
	private StructuredViewer viewer;
	
	public UpdatingContentProvider(ITreeContentProvider parent) {
		this.parent = parent;
	}

	public void dispose() {
		parent.dispose();
	}

	public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {
		if (viewer instanceof StructuredViewer)
			this.viewer = (StructuredViewer) viewer;
		parent.inputChanged(viewer, oldInput, newInput);
	}

	public Object[] getElements(Object inputElement) {
		return IconRenderingWorker.addIcons(viewer, parent.getElements(inputElement));
	}

	public Object[] getChildren(Object parentElement) {
		return IconRenderingWorker.addIcons(viewer, parent.getChildren(parentElement));
	}

	public Object getParent(Object element) {
		return parent.getParent(element);
	}

	public boolean hasChildren(Object element) {
		return parent.hasChildren(element);
	}

}
