package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.ide.graphical.util.ASTResourceProvider;

public abstract class AbstractCommand extends Command {
	
	private ASTResourceProvider astResourceProvider;
	
	public AbstractCommand(ASTResourceProvider provider) {
		this.astResourceProvider = provider;
	}
	
	public ASTResourceProvider getASTResourceProvider() {
		return astResourceProvider;
	}

}
