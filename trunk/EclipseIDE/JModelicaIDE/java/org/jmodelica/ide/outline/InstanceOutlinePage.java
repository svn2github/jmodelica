package org.jmodelica.ide.outline;

import org.eclipse.jface.viewers.DoubleClickEvent;
import org.eclipse.jface.viewers.IDoubleClickListener;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.texteditor.AbstractTextEditor;
import org.jmodelica.ide.helpers.Util;

public class InstanceOutlinePage extends OutlinePage implements IDoubleClickListener {

	public InstanceOutlinePage(AbstractTextEditor editor) {
		super(editor);
	}

	@Override
	protected void rootChanged(TreeViewer viewer) {
	}

	@Override
	protected ITreeContentProvider getContentProvider() {
		return new InstanceOutlineContentProvider();
	}

	@Override
	public void createControl(Composite parent) {
		super.createControl(parent);
		getTreeViewer().addDoubleClickListener(this);
	}

	public void doubleClick(DoubleClickEvent event) {
		Object elem = Util.getSelected(event.getSelection());
		Util.openAndSelect(getSite().getPage(), elem);
	}
}
