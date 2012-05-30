package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.RequestConstants;
import org.eclipse.gef.commands.Command;
import org.eclipse.gef.requests.ChangeBoundsRequest;
import org.jmodelica.icons.Component;
import org.jmodelica.icons.coord.Point;


public abstract class MoveComponentCommand extends Command {
	
	private Point newOrigin;
	private Point oldOrigin;
	private ChangeBoundsRequest request;
	private Component component;

	public MoveComponentCommand(Component component, ChangeBoundsRequest req) {
		if (component == null || req == null) {
			throw new IllegalArgumentException();
		}
		this.component = component;
		this.request = req;
		setLabel("move");
	}

	public boolean canExecute() {
		Object type = request.getType();
		return (RequestConstants.REQ_MOVE_CHILDREN.equals(type));
	}
	
	
	protected abstract Point calculateNewOrigin();
	
	public void execute() {
		oldOrigin = component.getPlacement().getTransformation().getOrigin();
		newOrigin = calculateNewOrigin();
		redo();
	}

	public void redo() {
		component.getPlacement().getTransformation().setOrigin(newOrigin);
	}

	public void undo() {
		component.getPlacement().getTransformation().setOrigin(oldOrigin);
	}
}
