package org.jmodelica.ide.graphical.edit.policies;

import org.eclipse.gef.commands.Command;
import org.eclipse.gef.editpolicies.ConnectionEditPolicy;
import org.eclipse.gef.requests.GroupRequest;
import org.jmodelica.ide.graphical.commands.DeleteConnectionCommand;
import org.jmodelica.ide.graphical.edit.parts.ConnectionPart;

public class ConnectionPolicy extends ConnectionEditPolicy {
	
	private ConnectionPart connection;
	
	public ConnectionPolicy(ConnectionPart connection) {
		this.connection = connection;
	}

	@Override
	protected Command getDeleteCommand(GroupRequest request) {
		return new DeleteConnectionCommand(connection.getConnection());
	}

}
