package org.jmodelica.ide.graphical.commands;

import org.jmodelica.icons.Component;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.ide.graphical.util.ASTResourceProvider;

public abstract class MoveComponentCommand extends AbstractCommand {

	private Point newOrigin;
	private Point oldOrigin;
	private String componentName;

	public MoveComponentCommand(String componentName, ASTResourceProvider provider) {
		super(provider);
		this.componentName = componentName;
		setLabel("move");
	}

	protected abstract Point calculateNewOrigin();

	@Override
	public void execute() {
		Component component = getASTResourceProvider().getComponentByName(componentName);
		if (component == null)
			return;

		oldOrigin = component.getPlacement().getTransformation().getOrigin();
		newOrigin = calculateNewOrigin();
		redo();
	}

	@Override
	public void redo() {
		Component component = getASTResourceProvider().getComponentByName(componentName);
		if (component == null)
			return;

		component.getPlacement().getTransformation().setOrigin(newOrigin);
	}

	@Override
	public void undo() {
		Component component = getASTResourceProvider().getComponentByName(componentName);
		if (component == null)
			return;

		component.getPlacement().getTransformation().setOrigin(oldOrigin);
	}
}
