package org.jmodelica.ide.documentation;

import org.eclipse.jface.action.IMenuManager;
import org.eclipse.ui.navigator.CommonActionProvider;
import org.eclipse.ui.navigator.ICommonMenuConstants;
import org.eclipse.ui.navigator.ICommonViewerSite;
import org.eclipse.ui.navigator.ICommonViewerWorkbenchSite;

public class ExplorerActionProvider extends CommonActionProvider{
	
	private ViewDocumentationAction viewDocAction;
	private GenerateDocumentationAction genDocAction;
	
	@Override
	public void init(org.eclipse.ui.navigator.ICommonActionExtensionSite site) {
		super.init(site);
		ICommonViewerSite viewSite = site.getViewSite();
		if (viewSite instanceof ICommonViewerWorkbenchSite) {
			ICommonViewerWorkbenchSite wbs = (ICommonViewerWorkbenchSite) viewSite;
			viewDocAction = new ViewDocumentationAction(wbs.getPage(), wbs.getSelectionProvider());
			genDocAction = new GenerateDocumentationAction(wbs.getPage(), wbs.getSelectionProvider());
		}
	}
	
	@Override
	public void fillContextMenu(IMenuManager menu){
		menu.appendToGroup(ICommonMenuConstants.GROUP_OPEN, viewDocAction);
		menu.appendToGroup(ICommonMenuConstants.GROUP_OPEN, genDocAction);
	}
}
