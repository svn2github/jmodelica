package org.jmodelica.ide.documentation;

import javax.swing.JFileChooser;
import javax.swing.JOptionPane;
import javax.swing.JTextArea;
import javax.swing.SwingUtilities;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.viewers.ISelectionProvider;
import org.eclipse.ui.IEditorReference;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.ide.IDE;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.FullClassDecl;

public class GenerateDocumentationAction extends Action{

	private IWorkbenchPage page;
	private ISelectionProvider selectionProvider;

	public GenerateDocumentationAction(IWorkbenchPage page, ISelectionProvider selectionProvider) {
		this.page = page;
		this.selectionProvider = selectionProvider;
		setText("Generate Documentation");
	}

	@Override
	public boolean isEnabled() {
		Object elem = Util.getSelected(selectionProvider.getSelection());
		return elem instanceof ASTNode<?>;
	}
	
	@Override
	public void run() {
		boolean noWorkBench = false;
		boolean found = false;
		Object elem = Util.getSelected(selectionProvider.getSelection());
		if (elem instanceof FullClassDecl) {
			try {
				IEditorReference[] editors = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().getEditorReferences();
				String name = Generator.getFullPath(((FullClassDecl) elem));
				for (IEditorReference editor : editors){
					if (editor.getEditor(false) instanceof DocumentationEditor && ((DocumentationEditor)editor.getEditor(false)).getCurrenetClass().equals(name)){
						PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().activate(editor.getPart(true));
						found = true;
						((DocumentationEditor)editor.getEditor(false)).generateDocumentation((FullClassDecl)elem);
					}
				}
			} catch (NullPointerException e){
				noWorkBench = true;
			}
			if (noWorkBench || !found){
				try {
					IDE.openEditor(page, new DocumentationEditorInput((FullClassDecl) elem, true), "org.jmodelica.ide.documentation.documentationEditor", true);
				} catch (PartInitException e) {
					System.err.println("Unable to open file: " + elem);
				}			
			}
		}
	}
}
