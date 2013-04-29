package org.jmodelica.ide.graphical;

import org.eclipse.gef.ui.actions.ActionBarContributor;
import org.eclipse.gef.ui.actions.DeleteRetargetAction;
import org.eclipse.gef.ui.actions.GEFActionConstants;
import org.eclipse.gef.ui.actions.RedoRetargetAction;
import org.eclipse.gef.ui.actions.UndoRetargetAction;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.actions.ActionFactory;
import org.eclipse.ui.actions.RetargetAction;
import org.jmodelica.ide.graphical.actions.ShowGridAction;
import org.jmodelica.ide.graphical.actions.SnapToGridAction;

public class EditorActionBarContributor extends ActionBarContributor {

	@Override
	protected void buildActions() {
		addRetargetAction(new DeleteRetargetAction());
		addRetargetAction(new UndoRetargetAction());
		addRetargetAction(new RedoRetargetAction());
		addRetargetAction(new RetargetAction(ShowGridAction.ID, "Show Grid", IAction.AS_CHECK_BOX));
		addRetargetAction(new RetargetAction(SnapToGridAction.ID, "Snap to Grid", IAction.AS_CHECK_BOX));
		addRetargetAction(new RetargetAction(GEFActionConstants.TOGGLE_SNAP_TO_GEOMETRY, "Snap to Geometry", IAction.AS_CHECK_BOX));
	}

	@Override
	public void contributeToToolBar(IToolBarManager toolBarManager) {
		toolBarManager.add(getAction(ActionFactory.UNDO.getId()));
		toolBarManager.add(getAction(ActionFactory.REDO.getId()));
		toolBarManager.add(getAction(ShowGridAction.ID));
		toolBarManager.add(getAction(SnapToGridAction.ID));
		toolBarManager.add(getAction(GEFActionConstants.TOGGLE_SNAP_TO_GEOMETRY));
		toolBarManager.add(new Action("Rebuild") {
			@Override
			public void run() {
				((Editor) PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().getActiveEditor()).forceRebuild();
			}
		});
		toolBarManager.add(new Action("Refresh") {
			@Override
			public void run() {
				((Editor) PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().getActiveEditor()).forceRefresh();
			}
		});
	}

	@Override
	protected void declareGlobalActionKeys() {
		// currently none
	}

}
