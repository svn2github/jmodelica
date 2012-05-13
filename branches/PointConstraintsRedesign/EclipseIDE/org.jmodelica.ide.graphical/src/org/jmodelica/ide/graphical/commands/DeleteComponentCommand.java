package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.Component;
import org.jmodelica.icons.Icon;

public class DeleteComponentCommand extends Command {
	private Component component;
	private Icon parent;
	
	public DeleteComponentCommand(Icon parent, Component component) {
		this.component = component;
		this.parent = parent;
		setLabel("remove component");
	}
	
	@Override
	public void execute() {
		parent.removeSubComponent(component);
	}
	
	@Override
	public void undo() {
		parent.addSubcomponent(component);
	}
}
