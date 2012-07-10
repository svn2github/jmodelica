package org.jmodelica.ide.graphical.commands;

import java.util.Arrays;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.Connection;
import org.jmodelica.icons.Connector;
import org.jmodelica.icons.coord.Point;

public abstract class CreateConnectionCommand extends Command {
	
	private Connector source;
	private Connector target;
	private Connection connection;
	
	public CreateConnectionCommand(Connector source) {
		this.source = source;
		setLabel("add connection");
	}
	
	@Override
	public boolean canExecute() {
		if (source == target) {
			return false;
		}
		for (Connection con : source.getTargetConnections()) {
			if (con.getTargetConnector() == target) {
				return false;
			}
		}
		for (Connection con : source.getSourceConnections()) {
			if (con.getSourceConnector() == target) {
				return false;
			}
		}
		return true;
	}
	
	protected abstract void initConnection(Connection c);
	
	@Override
	public void execute() {
		connection = new Connection();
		initConnection(connection);
		connection.setSourceConnector(source);
		connection.setTargetConnector(target);
		connection.setPoints(Arrays.asList(new Point(), new Point()));
		redo();
	}
	
	@Override
	public void undo() {
		connection.disconnect();
	}
	
	@Override
	public void redo() {
		connection.connect();
	}

	public void setTarget(Connector model) {
		target = model;
	}

}
