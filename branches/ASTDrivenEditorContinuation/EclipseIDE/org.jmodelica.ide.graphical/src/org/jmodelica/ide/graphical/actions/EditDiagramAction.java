package org.jmodelica.ide.graphical.actions;

import org.eclipse.jface.viewers.ISelectionProvider;
import org.eclipse.ui.IWorkbenchPage;

public class EditDiagramAction extends EditAction {
	
	public EditDiagramAction(IWorkbenchPage page, ISelectionProvider selectionProvider) {
		super(page, selectionProvider, "Edit Diagram");
	}

	@Override
	protected boolean editIcon() {
		return false;
	}
}