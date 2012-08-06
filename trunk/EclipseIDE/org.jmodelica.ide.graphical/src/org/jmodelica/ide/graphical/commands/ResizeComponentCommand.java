package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.coord.Extent;
import org.jmodelica.ide.graphical.proxy.ComponentProxy;

public abstract class ResizeComponentCommand extends Command {

	private Extent newExtent;
	private Extent oldExtent;
	private ComponentProxy component;

	public ResizeComponentCommand(ComponentProxy component) {
		this.component = component;
		setLabel("resize");
	}

	protected abstract Extent calculateNewExtent();

	@Override
	public void execute() {
		oldExtent = component.getPlacement().getTransformation().getExtent();
		newExtent = calculateNewExtent();
		redo();
	}

	@Override
	public void redo() {
		component.getPlacement().getTransformation().setExtent(newExtent);
	}

	@Override
	public void undo() {
		component.getPlacement().getTransformation().setExtent(oldExtent);
	}
}
