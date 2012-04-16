package org.jmodelica.ide.graphical.editparts;


import org.eclipse.gef.Request;
import org.eclipse.gef.commands.Command;
import org.eclipse.gef.editpolicies.ComponentEditPolicy;
import org.jmodelica.ide.graphical.actions.RotateAction;

public abstract class RotationEditPolicy extends ComponentEditPolicy {

	@Override
	public Command getCommand(Request request) {
		if (RotateAction.ROTATE_45_CCW_REQUEST.equals(request.getType()))
			return createRotateCommand(request, 45);
		if (RotateAction.ROTATE_90_CCW_REQUEST.equals(request.getType()))
			return createRotateCommand(request, 90);
		if (RotateAction.ROTATE_180_REQUEST.equals(request.getType()))
			return createRotateCommand(request, 180);
		if (RotateAction.ROTATE_90_CW_REQUEST.equals(request.getType()))
			return createRotateCommand(request, -90);
		if (RotateAction.ROTATE_45_CW_REQUEST.equals(request.getType()))
			return createRotateCommand(request, -45);
		
		return super.getCommand(request);
	}
	
	abstract protected Command createRotateCommand(Request request, double angle);

}
