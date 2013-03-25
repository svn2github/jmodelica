package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.ide.graphical.proxy.AbstractDiagramProxy;
import org.jmodelica.ide.graphical.proxy.ConnectionProxy;

public class DeleteConnectionCommand extends Command {
	AbstractDiagramProxy proxy;
	ConnectionProxy connection;
	private String sourceDiagramName;
	private String targetDiagramName;

	public DeleteConnectionCommand(ConnectionProxy connection) {
		this.connection = connection;
		this.sourceDiagramName = connection.getSource().buildDiagramName();
		this.targetDiagramName = connection.getTarget().buildDiagramName();
		System.out.println(sourceDiagramName+"--"+targetDiagramName);
		proxy = connection.getProxy();
		setLabel("remove connection");
	}

	@Override
	public void execute() {
		connection.disconnect();
	}

	@Override
	public void undo() {
		proxy.addConnection(sourceDiagramName, targetDiagramName);
	}
	
	@Override
	public void redo(){} //cant do
}
