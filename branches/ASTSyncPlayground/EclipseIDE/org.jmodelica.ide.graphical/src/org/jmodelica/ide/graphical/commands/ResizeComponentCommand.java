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
		component.getDiagram().resizeComponent(component, newExtent.getP1().getX(),newExtent.getP1().getY(), newExtent.getP2().getX(),newExtent.getP2().getY());
	}

	@Override
	public void undo() {
		component.getPlacement().getTransformation().setExtent(oldExtent);
		component.getDiagram().resizeComponent(component, oldExtent.getP1().getX(),oldExtent.getP1().getY(), oldExtent.getP2().getX(),oldExtent.getP2().getY());
	}
}
