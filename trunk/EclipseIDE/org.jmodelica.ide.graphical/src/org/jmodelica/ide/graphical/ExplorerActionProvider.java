package org.jmodelica.ide.graphical;

import org.eclipse.jface.action.IMenuManager;
import org.eclipse.ui.navigator.CommonActionProvider;
import org.eclipse.ui.navigator.ICommonMenuConstants;
import org.eclipse.ui.navigator.ICommonViewerSite;
import org.eclipse.ui.navigator.ICommonViewerWorkbenchSite;
import org.jmodelica.ide.graphical.actions.EditDiagramAction;
import org.jmodelica.ide.graphical.actions.EditIconAction;

public class ExplorerActionProvider extends CommonActionProvider {
	
	private EditDiagramAction editDiagramAction;
	private EditIconAction editIconAction;
	
	@Override
	public void init(org.eclipse.ui.navigator.ICommonActionExtensionSite site) {
		super.init(site);
		ICommonViewerSite viewSite = site.getViewSite();
		if (viewSite instanceof ICommonViewerWorkbenchSite) {
			ICommonViewerWorkbenchSite wbs = (ICommonViewerWorkbenchSite) viewSite;
			editDiagramAction = new EditDiagramAction(wbs.getPage(), wbs.getSelectionProvider());
			editIconAction  = new EditIconAction(wbs.getPage(), wbs.getSelectionProvider());
		}
	}
	
	@Override
	public void fillContextMenu(IMenuManager menu) {
		if (editDiagramAction.isEnabled())
			menu.appendToGroup(ICommonMenuConstants.GROUP_OPEN, editDiagramAction);
		if (editIconAction.isEnabled())
			menu.appendToGroup(ICommonMenuConstants.GROUP_OPEN, editIconAction);
	}
	
}
