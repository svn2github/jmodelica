package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.ide.graphical.proxy.ConnectionProxy;
import org.jmodelica.ide.graphical.proxy.ConnectorProxy;

public abstract class CreateConnectionCommand extends Command {

	private ConnectorProxy source;
	private ConnectorProxy target;
	private ConnectionProxy connection;

	public CreateConnectionCommand(ConnectorProxy source) {
		this.source = source;
		setLabel("add connection");
	}

	public void setTarget(ConnectorProxy model) {
		target = model;
	}

	@Override
	public boolean canExecute() {
		if (target == null)
			return true;
		if (source == target) {
			return false;
		}
		for (ConnectionProxy con : source.getTargetConnections()) {
			if (con.getSourceID().equals(target.getQualifiedComponentName())) {
				return false;
			}
		}
		for (ConnectionProxy con : source.getSourceConnections()) {
			if (con.getTargetID().equals(target.getQualifiedComponentName())) {
				return false;
			}
		}
		return true;
	}

	protected abstract void initConnection(ConnectionProxy connection);

	@Override
	public void execute() {
		connection = new ConnectionProxy(source.getQualifiedComponentName(), target.getQualifiedComponentName(), source.getDiagram(), false);
		initConnection(connection);
		redo();
	}

	@Override
	public void redo() {
		connection.connect();
	}

	@Override
	public void undo() {
		connection.disconnect();
	}

}
