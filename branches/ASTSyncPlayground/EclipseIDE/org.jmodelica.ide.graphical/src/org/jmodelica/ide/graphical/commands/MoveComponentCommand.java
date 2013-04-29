package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.ide.graphical.proxy.ComponentProxy;

public abstract class MoveComponentCommand extends Command {

	private Point newOrigin;
	private Point oldOrigin;
	private ComponentProxy component;

	public MoveComponentCommand(ComponentProxy component) {
		this.component = component;
		setLabel("move");
	}

	protected abstract Point calculateNewOrigin();

	@Override
	public void execute() {
		oldOrigin = component.getPlacement().getTransformation().getOrigin();
		newOrigin = calculateNewOrigin();
		redo();
	}

	@Override
	public void redo() {
		component.getPlacement().getTransformation().setOrigin(newOrigin);
		component.getDiagram().moveComponent(component, newOrigin.getX(),newOrigin.getY());
	}

	@Override
	public void undo() {
		component.getPlacement().getTransformation().setOrigin(oldOrigin);
		component.getDiagram().moveComponent(component, oldOrigin.getX(),oldOrigin.getY());
	}
}
