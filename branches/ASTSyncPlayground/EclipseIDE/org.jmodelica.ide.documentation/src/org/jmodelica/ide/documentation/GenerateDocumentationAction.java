package org.jmodelica.ide.documentation;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.viewers.ISelectionProvider;
import org.eclipse.ui.IEditorReference;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.ide.IDE;
import org.jmodelica.ide.helpers.ICachedOutlineNode;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.ide.sync.CachedClassDecl;

public class GenerateDocumentationAction extends Action {

	private IWorkbenchPage page;
	private ISelectionProvider selectionProvider;

	public GenerateDocumentationAction(IWorkbenchPage page,
			ISelectionProvider selectionProvider) {
		this.page = page;
		this.selectionProvider = selectionProvider;
		setText("Generate Documentation");
	}

	@Override
	public boolean isEnabled() {
		Object elem = Util.getSelected(selectionProvider.getSelection());
		return elem instanceof ICachedOutlineNode;
	}

	/**
	 * Go through the open editors to see if the selected class is already open.
	 * If so, it is brought to the front. If not, a new editor for the selected
	 * class is opened.
	 */
	@Override
	public void run() {
		boolean noWorkBench = false;
		boolean found = false;
		Object elem = Util.getSelected(selectionProvider.getSelection());
		if (elem instanceof CachedClassDecl) {
			try {
				IEditorReference[] editors = PlatformUI.getWorkbench()
						.getActiveWorkbenchWindow().getActivePage()
						.getEditorReferences();
				CachedClassDecl cd = (CachedClassDecl) elem;
				String classIdentifier = cd.getASTPath().get(0).id();
				for (IEditorReference editor : editors) {
					if (editor.getEditor(false) instanceof DocumentationEditor
							&& ((DocumentationEditor) editor.getEditor(false))
									.getCurrentClassIdentifier().equals(
											classIdentifier)) {
						PlatformUI.getWorkbench().getActiveWorkbenchWindow()
								.getActivePage().activate(editor.getPart(true));
						found = true;
						((DocumentationEditor) editor.getEditor(false))
								.generateDocumentation(cd.containingFileName(),
										cd.getASTPath());
					}
				}
			} catch (NullPointerException e) {
				noWorkBench = true;
			}
			if (noWorkBench || !found) {
				try {
					CachedClassDecl cd = (CachedClassDecl) elem;
					IDE.openEditor(
							page,
							new DocumentationEditorInput(cd
									.containingFileName(), cd.getASTPath(),
									true),
							"org.jmodelica.ide.documentation.documentationEditor",
							true);
				} catch (PartInitException e) {
					System.err.println("Unable to open file: " + elem);
				}
			}
		}
	}
}