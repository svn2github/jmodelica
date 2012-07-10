package org.jmodelica.ide.graphical.actions;

import org.eclipse.jface.viewers.ISelectionProvider;
import org.eclipse.ui.IWorkbenchPage;

public class EditIconAction extends EditAction {
	
	public EditIconAction(IWorkbenchPage page, ISelectionProvider selectionProvider) {
		super(page, selectionProvider, "Edit Icon");
	}

	@Override
	protected boolean editIcon() {
		return true;
	}
}