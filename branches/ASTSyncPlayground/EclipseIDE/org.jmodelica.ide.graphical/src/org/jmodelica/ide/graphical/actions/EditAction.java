package org.jmodelica.ide.graphical.actions;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.viewers.ISelectionProvider;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.ide.IDE;
import org.jmodelica.ide.graphical.GraphicalEditorInput;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.ide.outline.cache.CachedASTNode;
import org.jmodelica.ide.outline.cache.CachedClassDecl;

public abstract class EditAction extends Action {

	private IWorkbenchPage page;
	private ISelectionProvider selectionProvider;

	public EditAction(IWorkbenchPage page, ISelectionProvider selectionProvider, String text) {
		this.page = page;
		this.selectionProvider = selectionProvider;
		setText(text);
	}

	@Override
	public boolean isEnabled() {
		Object elem = Util.getSelected(selectionProvider.getSelection());
		return elem instanceof CachedASTNode;
	}

	@Override
	public void run() {
		Object elem = Util.getSelected(selectionProvider.getSelection());
		if (elem instanceof CachedClassDecl) {
			try {
				IDE.openEditor(page, new GraphicalEditorInput((CachedClassDecl) elem, editIcon()), "org.jmodelica.ide.graphical.editor", true);
			} catch (PartInitException e) {
				System.err.println("Unable to open file: " + elem);
			}
		}
	}
	
	protected abstract boolean editIcon();
}