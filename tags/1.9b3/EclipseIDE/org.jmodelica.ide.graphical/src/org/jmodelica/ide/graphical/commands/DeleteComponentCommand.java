package org.jmodelica.ide.graphical.commands;

import java.util.List;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.ide.graphical.proxy.ComponentProxy;
import org.jmodelica.ide.graphical.proxy.ConnectionProxy;

public class DeleteComponentCommand extends Command {
	private ComponentProxy component;
	private String className;
	private String componentName;
	private Placement placement;
	private List<ConnectionProxy> removedConnections;

	public DeleteComponentCommand(ComponentProxy component) {
		this.component = component;
		setLabel("remove component");
	}

	@Override
	public void execute() {
		className = component.getQualifiedClassName();
		componentName = component.getComponentName();
		placement = component.getPlacement();
		removedConnections = component.getConnections();
		for (ConnectionProxy connection : removedConnections) {
			connection.disconnect();
		}
		component.getDiagram().removeComponent(component);
	}

	@Override
	public void undo() {
		component.getDiagram().addComponent(className, componentName, placement);
		for (ConnectionProxy connection : removedConnections) {
			connection.connect();
		}
	}
}
