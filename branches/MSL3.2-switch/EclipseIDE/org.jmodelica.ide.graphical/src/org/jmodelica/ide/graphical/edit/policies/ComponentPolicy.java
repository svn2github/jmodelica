package org.jmodelica.ide.graphical.edit.policies;

import org.eclipse.gef.Request;
import org.eclipse.gef.commands.Command;
import org.eclipse.gef.editpolicies.ComponentEditPolicy;
import org.eclipse.gef.requests.GroupRequest;
import org.jmodelica.ide.graphical.actions.RotateAction;
import org.jmodelica.ide.graphical.commands.DeleteComponentCommand;
import org.jmodelica.ide.graphical.commands.RotateComponentCommand;
import org.jmodelica.ide.graphical.edit.parts.ComponentPart;

public class ComponentPolicy extends ComponentEditPolicy {

	private ComponentPart component;

	public ComponentPolicy(ComponentPart component) {
		this.component = component;
	}

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

	protected Command createRotateCommand(Request request, double angle) {
		return new RotateComponentCommand(component.getModel(), angle);
	}

	@Override
	protected Command createDeleteCommand(GroupRequest deleteRequest) {
		return new DeleteComponentCommand(component.getModel());
	}

}
