package org.jmodelica.ide.graphicalhtml;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.viewers.ISelectionProvider;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.ide.IDE;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.FullClassDecl;

public class ViewDocumentationAction extends Action{

	private IWorkbenchPage page;
	private ISelectionProvider selectionProvider;
	
	public ViewDocumentationAction(IWorkbenchPage page, ISelectionProvider selectionProvider) {
		this.page = page;
		this.selectionProvider = selectionProvider;
		setText("View Documentation");
	}
	
	@Override
	public boolean isEnabled() {
		Object elem = Util.getSelected(selectionProvider.getSelection());
		return elem instanceof ASTNode<?>;
	}

	@Override
	public void run() {
		Object elem = Util.getSelected(selectionProvider.getSelection());
		if (elem instanceof FullClassDecl) {
			try {
				IDE.openEditor(page, new MyEditorInput((FullClassDecl) elem), "org.jmodelica.ide.graphicalhtml.myEditor", true);
			} catch (PartInitException e) {
				System.err.println("Unable to open file: " + elem);
			}
		}
	}
}
