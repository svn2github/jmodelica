package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.ide.graphical.proxy.ComponentProxy;

public class RotateComponentCommand extends Command {

	private ComponentProxy component;
	private double angle;

	public RotateComponentCommand(ComponentProxy component, double angle) {
		this.component = component;
		this.angle = angle;
	}

	@Override
	public boolean canExecute() {
		return true;
	}

	@Override
	public void execute() {
		redo();
	}

	@Override
	public void redo() {
		component.getPlacement().getTransformation().setRotation(component.getPlacement().getTransformation().getRotation() + angle);
	}

	@Override
	public void undo() {
		component.getPlacement().getTransformation().setRotation(component.getPlacement().getTransformation().getRotation() - angle);
	}

}
