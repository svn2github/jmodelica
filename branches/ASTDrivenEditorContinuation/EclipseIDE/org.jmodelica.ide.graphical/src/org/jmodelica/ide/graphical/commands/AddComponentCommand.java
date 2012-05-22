package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.Component;
import org.jmodelica.icons.Diagram;
import org.jmodelica.icons.Layer;

public class AddComponentCommand extends Command {
	
	private Diagram diagram;
	private Component component;
	
	public AddComponentCommand(Diagram d, Component c) {
		diagram = d;
		component = c;
		setLabel("add component");
	}
	
	@Override
	public boolean canExecute() {
		return component.getIcon().getLayer() != Layer.NO_LAYER;
	}
	
	@Override
	public void execute() {
		redo();
	}
	
	@Override
	public void redo() {
		diagram.addSubcomponent(component);
	}
	
	@Override
	public void undo() {
		diagram.removeSubComponent(component);
	}

}
