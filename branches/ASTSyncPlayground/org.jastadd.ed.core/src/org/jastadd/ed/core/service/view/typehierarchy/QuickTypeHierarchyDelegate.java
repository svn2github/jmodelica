package org.jastadd.ed.core.service.view.typehierarchy;

import org.eclipse.jface.action.IAction;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IInformationControl;
import org.eclipse.jface.text.IInformationControlCreator;
import org.eclipse.jface.text.information.InformationPresenter;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.IEditorActionDelegate;
import org.eclipse.ui.IEditorPart;
import org.jastadd.ed.core.Editor;
import org.jastadd.ed.core.model.node.ILocalRootHandle;
import org.jastadd.ed.core.service.view.TreeViewInformationControl;

public class QuickTypeHierarchyDelegate implements IEditorActionDelegate {

	protected IEditorPart fEditorPart;
	protected ISelection fSelection;
	
	@Override
	public void run(IAction action) {
		if (fEditorPart instanceof Editor) {
			Editor editor = (Editor)fEditorPart;
			ILocalRootHandle proxy = editor.getLocalRootHandle();
			IInformationControlCreator infoControlCreator = new IInformationControlCreator() {
				public IInformationControl createInformationControl(Shell parent) {
					return new TreeViewInformationControl(parent);
				}	
			};
			InformationPresenter infoPresenter = new InformationPresenter(infoControlCreator);
			QuickTypeHierarchyInformationProvider infoProvider = 
				new QuickTypeHierarchyInformationProvider(proxy);
			infoPresenter.setInformationProvider(infoProvider, IDocument.DEFAULT_CONTENT_TYPE);
			editor.showInformationPresenter(infoPresenter);
		}
	}
	
	@Override
	public void selectionChanged(IAction action, ISelection selection) {
		fSelection = selection;
	}

	@Override
	public void setActiveEditor(IAction action, IEditorPart targetEditor) {
		fEditorPart = targetEditor;
	}

}
