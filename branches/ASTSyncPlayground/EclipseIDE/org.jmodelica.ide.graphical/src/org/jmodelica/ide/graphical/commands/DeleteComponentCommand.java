package org.jmodelica.ide.graphical.commands;

import java.util.Stack;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.ide.graphical.proxy.AbstractDiagramProxy;
import org.jmodelica.ide.graphical.proxy.ComponentProxy;
import org.jmodelica.ide.graphical.proxy.ConnectionProxy;

public class DeleteComponentCommand extends Command {
	AbstractDiagramProxy proxy;
	private ComponentProxy component;
	private String className;
	private String componentName;
	private Placement placement;
	private Stack<String> removedConnections = new Stack<String>();

	public DeleteComponentCommand(ComponentProxy component) {
		this.component = component;
		setLabel("remove component");
	}

	@Override
	public void execute() {
		proxy = component.getDiagram();
		className = component.getQualifiedClassName();
		System.out.println("delete classneme=" + className);
		componentName = component.getComponentName();
		System.out.println("delete compname=" + componentName);
		placement = component.getPlacement();
		for (ConnectionProxy cp : component.getConnections()) {
			removedConnections.add(cp.getSource().buildDiagramName());
			removedConnections.add(cp.getTarget().buildDiagramName());
		}
		component.getDiagram().removeComponent(component);
	}

	@Override
	public void undo() { // TODO - dont have correct component name to recreate
		/*
		 * System.out.println("undo: classname="+className);
		 * System.out.println("componame="+componentName);
		 * System.out.println("placement==null?:"+(placement==null));
		 * proxy.addComponent(className, componentName, placement); while
		 * (removedConnections.size()>1) { String
		 * diagramName1=removedConnections.pop(); String
		 * diagramName2=removedConnections.pop();
		 * proxy.addConnection(diagramName1, diagramName2); }
		 */
	}
}
