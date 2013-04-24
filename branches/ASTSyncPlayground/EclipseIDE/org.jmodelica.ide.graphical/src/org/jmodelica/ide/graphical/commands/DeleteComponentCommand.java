package org.jmodelica.ide.graphical.commands;

import java.util.Stack;

import org.eclipse.gef.commands.Command;
import org.jmodelica.ide.graphical.proxy.AbstractDiagramProxy;
import org.jmodelica.ide.graphical.proxy.ComponentProxy;
import org.jmodelica.ide.graphical.proxy.ConnectionProxy;

public class DeleteComponentCommand extends Command {
	AbstractDiagramProxy proxy;
	private ComponentProxy component;
	private String className;
	private String componentName;
	
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
		componentName = component.getClassName();
		System.out.println("delete compname=" + componentName);
		
		System.out.println("delete syncname=" + component.getComponentDecl().syncName());
		System.out.println("delete astpath=" + component.getComponentDecl().getComponentASTPath());
		System.out.println("delete builddiagramnanem=" + component.buildDiagramName());

		for (ConnectionProxy cp : component.getConnections()) {
			removedConnections.add(cp.getSource().buildDiagramName());
			removedConnections.add(cp.getTarget().buildDiagramName());
		}
		component.getDiagram().removeComponent(component);
	}

	@Override
	public void undo() { // TODO - dont have correct component name to recreate
		proxy.undoRemoveComponent();
	}
}
