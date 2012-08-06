package org.jmodelica.ide.graphical.actions;

import org.eclipse.gef.ui.actions.SelectionAction;
import org.jmodelica.ide.graphical.Editor;
import org.jmodelica.ide.graphical.edit.parts.ComponentPart;

public class OpenComponentAction extends SelectionAction {
	
	public static final String OPEN_COMPONENT_ACTION = "openComponent";

	public OpenComponentAction(Editor part) {
		super(part);
		setId(OPEN_COMPONENT_ACTION);
		setText("Open Component");
	}
	
	@Override
	protected Editor getWorkbenchPart() {
		return (Editor) super.getWorkbenchPart();
	}

	@Override
	protected boolean calculateEnabled() {
		if (getSelectedObjects().size() != 1)
			return false;
		return getSelectedObjects().get(0) instanceof ComponentPart;
	}
	
	@Override
	public void run() {
		getWorkbenchPart().openSubComponent(((ComponentPart) getSelectedObjects().get(0)).getModel());
	}
}
