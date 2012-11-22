package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.ide.graphical.proxy.ConnectionProxy;

public class DeleteConnectionCommand extends Command {
	private ConnectionProxy connection;

	public DeleteConnectionCommand(ConnectionProxy connection) {
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
