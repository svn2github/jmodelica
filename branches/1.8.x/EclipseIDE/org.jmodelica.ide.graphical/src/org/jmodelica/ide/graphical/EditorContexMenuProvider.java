package org.jmodelica.ide.graphical;

import org.eclipse.gef.ContextMenuProvider;
import org.eclipse.gef.EditPartViewer;
import org.eclipse.gef.ui.actions.ActionRegistry;
import org.eclipse.gef.ui.actions.GEFActionConstants;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.MenuManager;
import org.eclipse.ui.actions.ActionFactory;
import org.jmodelica.ide.graphical.actions.OpenComponentAction;
import org.jmodelica.ide.graphical.actions.RotateAction;

public class EditorContexMenuProvider extends ContextMenuProvider {
	
	private ActionRegistry registry;

	public EditorContexMenuProvider(EditPartViewer viewer, ActionRegistry registry) {
		super(viewer);
		this.registry = registry;
	}

	@Override
	public void buildContextMenu(IMenuManager menu) {
		GEFActionConstants.addStandardActionGroups(menu);

		IAction action;
		
		action = registry.getAction(ActionFactory.UNDO.getId());
		menu.appendToGroup(GEFActionConstants.GROUP_UNDO, action);
		
		action = registry.getAction(ActionFactory.REDO.getId());
		menu.appendToGroup(GEFActionConstants.GROUP_UNDO, action);
		
		action = registry.getAction(ActionFactory.DELETE.getId());
		if (action.isEnabled())
			menu.appendToGroup(GEFActionConstants.GROUP_EDIT, action);
		
		action = registry.getAction(OpenComponentAction.OPEN_COMPONENT_ACTION);
		if (action.isEnabled())
			menu.appendToGroup(GEFActionConstants.GROUP_REST, action);
		
		MenuManager rotateMenu = new MenuManager("Rotate");

		action = registry.getAction(RotateAction.ROTATE_45_CCW_REQUEST);
		if (action.isEnabled())
			rotateMenu.add(action);

		action = registry.getAction(RotateAction.ROTATE_90_CCW_REQUEST);
		if (action.isEnabled())
			rotateMenu.add(action);

		action = registry.getAction(RotateAction.ROTATE_180_REQUEST);
		if (action.isEnabled())
			rotateMenu.add(action);

		action = registry.getAction(RotateAction.ROTATE_90_CW_REQUEST);
		if (action.isEnabled())
			rotateMenu.add(action);

		action = registry.getAction(RotateAction.ROTATE_45_CW_REQUEST);
		if (action.isEnabled())
			rotateMenu.add(action);
		
		if (!rotateMenu.isEmpty())
			menu.appendToGroup(GEFActionConstants.GROUP_REST, rotateMenu);
	}

}
