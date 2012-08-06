package org.jmodelica.ide.graphical.actions;

import org.eclipse.gef.EditPart;
import org.eclipse.gef.Request;
import org.eclipse.gef.commands.CompoundCommand;
import org.eclipse.gef.ui.actions.SelectionAction;
import org.eclipse.ui.IWorkbenchPart;
import org.jmodelica.ide.graphical.edit.parts.ComponentPart;
import org.jmodelica.ide.graphical.edit.parts.ConnectionPart;
import org.jmodelica.ide.graphical.edit.parts.primitives.GraphicEditPart;


public class RotateAction extends SelectionAction {

	public static final String ROTATE_45_CW_REQUEST = "rotate45cw";
	public static final String ROTATE_90_CW_REQUEST = "rotate90cw";
	public static final String ROTATE_180_REQUEST = "rotate180";
	public static final String ROTATE_90_CCW_REQUEST = "rotate90ccw";
	public static final String ROTATE_45_CCW_REQUEST = "rotate45ccw";

	private Request request;

	public RotateAction(IWorkbenchPart part, int angle) {
		super(part);
		switch (angle) {
		case 90:
			setId(ROTATE_90_CCW_REQUEST);
			setText("90 CCW");
			request = new Request(ROTATE_90_CCW_REQUEST);
			break;
		case 45:
			setId(ROTATE_45_CCW_REQUEST);
			setText("45 CCW");
			request = new Request(ROTATE_45_CCW_REQUEST);
			break;
		case -45:
			setId(ROTATE_45_CW_REQUEST);
			setText("45 CW");
			request = new Request(ROTATE_45_CW_REQUEST);
			break;
		case -90:
			setId(ROTATE_90_CW_REQUEST);
			setText("90 CW");
			request = new Request(ROTATE_90_CW_REQUEST);
			break;
		case 180:
		case -180:
		default:
			setId(ROTATE_180_REQUEST);
			setText("180");
			request = new Request(ROTATE_180_REQUEST);
			break;
		}
	}

	@Override
	protected boolean calculateEnabled() {
		if (getSelectedObjects().isEmpty())
			return false;
		
		for (Object o : getSelectedObjects()) {
			if (!(o instanceof EditPart))
				return false;
			
			EditPart part = (EditPart) o;
			
			if (!(part instanceof ComponentPart || (part instanceof GraphicEditPart && !(part instanceof ConnectionPart))))
				return false;
		}
		return true;
	}

	@Override
	public void run() {
		CompoundCommand cc = new CompoundCommand();
		for (Object o : getSelectedObjects()) {
			EditPart part = (EditPart) o;
			cc.add(part.getCommand(request));
		}
		execute(cc);
	}

}
