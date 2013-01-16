package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.ide.graphical.proxy.AbstractDiagramProxy;
import org.jmodelica.ide.graphical.proxy.ComponentProxy;

public class AddComponentCommand extends Command {

	private AbstractDiagramProxy diagram;
	private String className;
	private Placement placement;

	private ComponentProxy component;

	public AddComponentCommand(AbstractDiagramProxy diagram, String className, Placement placement) {
		this.diagram = diagram;
		this.className = className;
		this.placement = placement;
		setLabel("add component");
	}

	@Override
	public void execute() {
		redo();
	}

	@Override
	public void redo() {
		component = diagram.addComponent(className, placement);
	}

	@Override
	public void undo() {
		diagram.removeComponent(component);
	}

}
