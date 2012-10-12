package org.jmodelica.ide.graphical.commands;

import org.jmodelica.icons.Component;
import org.jmodelica.ide.graphical.util.ASTResourceProvider;

public abstract class AddComponentCommand extends AbstractCommand {
	
	private String componentName;
	
	public AddComponentCommand(ASTResourceProvider provider) {
		super(provider);
		setLabel("add component");
	}
	
	protected abstract Component createComponent();
	
	@Override
	public void execute() {
		redo();
	}
	
	@Override
	public void redo() {
		Component c = createComponent();
		componentName = c.getComponentName();
		getASTResourceProvider().getDiagram().addSubcomponent(c);
	}
	
	@Override
	public void undo() {
		System.out.println(componentName);
		Component c = getASTResourceProvider().getComponentByName(componentName);
		System.out.println(c);
		if (c == null)
			return;
		
		getASTResourceProvider().getDiagram().removeSubComponent(c);
	}
	
}
