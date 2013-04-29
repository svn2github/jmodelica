package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.ide.graphical.proxy.ConnectionProxy;

public abstract class RemoveBendpointCommand extends Command {

	private ConnectionProxy connection;
	private int index;
	private Point oldPoint;

	public RemoveBendpointCommand(ConnectionProxy connection) {
		this.connection = connection;
		setLabel("remove bendpoint");
	}

	protected abstract Point calculateOldPoint();

	@Override
	public void execute() {
		oldPoint = calculateOldPoint();
		redo();
	}

	@Override
	public void redo() {
		Line line = connection.getLine();
		if (line == null) {
			System.err.println("Unable to redo remove line point, connection not found!");
			return;
		}
		index = line.getPoints().indexOf(oldPoint);
		if (index != -1) {
			line.getPoints().remove(index);
			line.pointsChanged();
		} else {
			System.err.println("Unable to redo remove line point, oldpoint is missing from pointlist, someone probably swapped it already!");
		}
		connection.getProxy().getDiagram().removeBendPoint(connection, index);
	}

	@Override
	public void undo() {
		Line line = connection.getLine();
		if (line == null) {
			System.err
					.println("Unable to undo remove line point, connection not found!");
			return;
		}
		if (index != -1) {
			line.getPoints().add(index, oldPoint);
			line.pointsChanged();
		} else {
			System.err
					.println("Unable to undo remove line point, index is invalid, someone probably changed the list already!");
		}
		connection
				.getProxy()
				.getDiagram()
				.addBendPoint(connection, oldPoint.getX(), oldPoint.getY(),
						index);
	}

}
