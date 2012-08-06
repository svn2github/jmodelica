package org.jmodelica.ide.graphical.edit.policies;

import org.eclipse.draw2d.geometry.Point;
import org.eclipse.gef.commands.Command;
import org.eclipse.gef.editpolicies.BendpointEditPolicy;
import org.eclipse.gef.requests.BendpointRequest;
import org.jmodelica.ide.graphical.commands.AddBendpointCommand;
import org.jmodelica.ide.graphical.commands.RemoveBendpointCommand;
import org.jmodelica.ide.graphical.commands.MoveBendpointCommand;
import org.jmodelica.ide.graphical.edit.parts.ConnectionPart;
import org.jmodelica.ide.graphical.util.Converter;
import org.jmodelica.ide.graphical.util.Transform;

public class ConnectionBendpointPolicy extends BendpointEditPolicy {
	
	private ConnectionPart connection;

	public ConnectionBendpointPolicy(ConnectionPart connection) {
		this.connection = connection;
	}

	@Override
	protected Command getMoveBendpointCommand(final BendpointRequest request) {
		return new MoveBendpointCommand(connection.getModel()) {

			@Override
			protected org.jmodelica.icons.coord.Point calculateOldPoint() {
				return connection.getModel().getPoints().get(request.getIndex() + 1);
			}

			@Override
			protected org.jmodelica.icons.coord.Point calculateNewPoint() {
				Point location = request.getLocation();
				connection.getFigure().translateToRelative(location);
				return Transform.yInverter.transform(connection.getTransform().getInverseTransfrom().transform(Converter.convert(location)));
			}

		};
	}

	@Override
	protected Command getDeleteBendpointCommand(final BendpointRequest request) {
		return new RemoveBendpointCommand(connection.getModel()) {

			@Override
			protected org.jmodelica.icons.coord.Point calculateOldPoint() {
				return connection.getModel().getPoints().get(request.getIndex() + 1);
			}
		};
	}

	@Override
	protected Command getCreateBendpointCommand(final BendpointRequest request) {
		return new AddBendpointCommand(connection.getModel()) {

			@Override
			protected int calculateIndex() {
				return request.getIndex() + 1;
			}

			@Override
			protected org.jmodelica.icons.coord.Point calculateNewPoint() {
				Point location = request.getLocation();
				connection.getFigure().translateToRelative(location);
				return Transform.yInverter.transform(connection.getTransform().getInverseTransfrom().transform(Converter.convert(location)));
			}
		};
	}

}
