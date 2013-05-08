package org.jmodelica.ide.documentation;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.viewers.ISelectionProvider;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.ide.IDE;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.ide.sync.CachedClassDecl;

public class ViewDocumentationAction extends Action {

	private IWorkbenchPage page;
	private ISelectionProvider selectionProvider;

	public ViewDocumentationAction(IWorkbenchPage page,
			ISelectionProvider selectionProvider) {
		this.page = page;
		this.selectionProvider = selectionProvider;
		setText("View Documentation");
	}

	@Override
	public boolean isEnabled() {
		Object elem = Util.getSelected(selectionProvider.getSelection());
		return elem instanceof CachedClassDecl;
	}

	@Override
	public void run() {
		Object elem = Util.getSelected(selectionProvider.getSelection());
		if (elem instanceof CachedClassDecl) {
			try {
				CachedClassDecl cd = (CachedClassDecl) elem;
				IDE.openEditor(
						page,
						new DocumentationEditorInput(cd.containingFileName(),
								cd.getASTPath(), false),
						"org.jmodelica.ide.documentation.documentationEditor",
						true);
			} catch (PartInitException e) {
				System.err.println("Unable to open file: " + elem);
			}
		}
	}
}