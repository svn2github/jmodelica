package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.RequestConstants;
import org.eclipse.gef.commands.Command;
import org.eclipse.gef.requests.ChangeBoundsRequest;
import org.jmodelica.icons.Component;
import org.jmodelica.icons.coord.Extent;


public abstract class ResizeComponentCommand extends Command {
	
	private Extent newExtent;
	private Extent oldExtent;
	private ChangeBoundsRequest request;
	private Component component;

	public ResizeComponentCommand(Component component, ChangeBoundsRequest req) {
		if (component == null || req == null) {
			throw new IllegalArgumentException();
		}
		this.component = component;
		this.request = req;
		setLabel("resize");
	}

	public boolean canExecute() {
		return RequestConstants.REQ_RESIZE_CHILDREN.equals(request.getType());
	}
	

	protected abstract Extent calculateNewExtent();
	
	public void execute() {
		oldExtent = component.getPlacement().getTransformation().getExtent();
		newExtent = calculateNewExtent();
		redo();
	}

	public void redo() {
		component.getPlacement().getTransformation().setExtent(newExtent);
	}

	public void undo() {
		component.getPlacement().getTransformation().setExtent(oldExtent);
	}
}
