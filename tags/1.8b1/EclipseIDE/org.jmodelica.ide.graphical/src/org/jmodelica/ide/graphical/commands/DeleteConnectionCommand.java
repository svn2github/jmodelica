package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.Connection;

public class DeleteConnectionCommand extends Command {
	private Connection connection;
	
	public DeleteConnectionCommand(Connection connection) {
		this.connection = connection;
		setLabel("remove connection");
	}
	
	@Override
	public void execute() {
		connection.disconnect();
	}
	
	@Override
	public void undo() {
		connection.connect();
	}
}
