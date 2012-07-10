package org.jmodelica.ide.graphical.commands;

import org.jmodelica.icons.Component;
import org.jmodelica.icons.coord.Extent;
import org.jmodelica.ide.graphical.util.ASTResourceProvider;

public abstract class ResizeComponentCommand extends AbstractCommand {

	private Extent newExtent;
	private Extent oldExtent;
	private String componentName;

	public ResizeComponentCommand(String componentName, ASTResourceProvider provider) {
		super(provider);
		this.componentName = componentName;
		setLabel("resize");
	}

	protected abstract Extent calculateNewExtent();

	@Override
	public void execute() {
		Component component = getASTResourceProvider().getComponentByName(componentName);
		if (component == null)
			return;

		oldExtent = component.getPlacement().getTransformation().getExtent();
		newExtent = calculateNewExtent();
		redo();
	}

	@Override
	public void redo() {
		Component component = getASTResourceProvider().getComponentByName(componentName);
		if (component == null)
			return;

		component.getPlacement().getTransformation().setExtent(newExtent);
	}

	@Override
	public void undo() {
		Component component = getASTResourceProvider().getComponentByName(componentName);
		if (component == null)
			return;

		component.getPlacement().getTransformation().setExtent(oldExtent);
	}
}
