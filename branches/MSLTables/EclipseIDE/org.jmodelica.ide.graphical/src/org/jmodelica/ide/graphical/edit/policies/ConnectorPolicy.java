package org.jmodelica.ide.graphical.edit.policies;

import java.util.Arrays;

import org.eclipse.gef.Request;
import org.eclipse.gef.commands.Command;
import org.eclipse.gef.editpolicies.GraphicalNodeEditPolicy;
import org.eclipse.gef.requests.CreateConnectionRequest;
import org.eclipse.gef.requests.ReconnectRequest;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.ide.graphical.commands.CreateConnectionCommand;
import org.jmodelica.ide.graphical.edit.parts.ConnectorPart;
import org.jmodelica.ide.graphical.graphics.TemporaryConnectionFigure;
import org.jmodelica.ide.graphical.proxy.ConnectionProxy;
import org.jmodelica.ide.graphical.proxy.ConnectorProxy;
import org.jmodelica.ide.graphical.util.Converter;

public class ConnectorPolicy extends GraphicalNodeEditPolicy {

	private ConnectorPart connector;

	public ConnectorPolicy(ConnectorPart connector) {
		this.connector = connector;
	}

	@Override
	protected TemporaryConnectionFigure createDummyConnection(Request req) {
		TemporaryConnectionFigure tmpConnectionFigure = new TemporaryConnectionFigure();
		tmpConnectionFigure.setForegroundColor(Converter.convert(connector.calculateConnectionColor()));
		return tmpConnectionFigure;
	}

	@Override
	protected Command getConnectionCreateCommand(CreateConnectionRequest request) {
		ConnectorProxy source = ((ConnectorPart) getHost()).getModel();
		CreateConnectionCommand cmd = new CreateConnectionCommand(source) {

			@Override
			protected void initConnection(ConnectionProxy c) {
				c.getLine().setColor(connector.calculateConnectionColor());
				c.getLine().setPoints(Arrays.asList(new Point(), new Point()));
			}

		};
		request.setStartCommand(cmd);
		return cmd;
	}

	@Override
	protected Command getConnectionCompleteCommand(CreateConnectionRequest request) {
		CreateConnectionCommand cmd = (CreateConnectionCommand) request.getStartCommand();
		cmd.setTarget(((ConnectorPart) getHost()).getModel());
		return cmd;
	}

	@Override
	protected Command getReconnectSourceCommand(ReconnectRequest request) {
		return null;
	}

	@Override
	protected Command getReconnectTargetCommand(ReconnectRequest request) {
		return null;
	}

}
