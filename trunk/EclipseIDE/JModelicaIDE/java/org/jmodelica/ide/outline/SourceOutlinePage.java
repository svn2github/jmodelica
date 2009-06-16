package org.jmodelica.ide.outline;

import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.ui.texteditor.AbstractTextEditor;

public class SourceOutlinePage extends OutlinePage {

	public SourceOutlinePage(AbstractTextEditor editor) {
		super(editor);
	}

	@Override
	protected void rootChanged(TreeViewer viewer) {
		viewer.expandToLevel(2);
	}
}