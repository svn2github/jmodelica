package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.ide.graphical.proxy.ConnectionProxy;

public abstract class MoveBendpointCommand extends Command {

	private ConnectionProxy connection;
	private Point newPoint;
	private Point oldPoint;

	public MoveBendpointCommand(ConnectionProxy connection) {
		this.connection = connection;
		setLabel("move bendpoint");
	}

	protected abstract Point calculateNewPoint();

	protected abstract Point calculateOldPoint();

	@Override
	public void execute() {
		oldPoint = calculateOldPoint();
		newPoint = calculateNewPoint();
		redo();
	}

	@Override
	public void redo() {
		Line line = connection.getLine();
		if (line == null) {
			System.err.println("Unable to redo move line point, connection not found!");
			return;
		}
		int index = line.getPoints().indexOf(oldPoint);
		if (index != -1) {
			line.getPoints().set(index, newPoint);
			line.pointsChanged();
		} else {
			System.err.println("Unable to redo move line point, oldpoint is missing from pointlist, someone probably swapped it already!");
		}
	}

	@Override
	public void undo() {
		Line line = connection.getLine();
		if (line == null) {
			System.err.println("Unable to undo move line point, connection not found!");
			return;
		}
		int index = line.getPoints().indexOf(newPoint);
		if (index != -1) {
			line.getPoints().set(index, oldPoint);
			line.pointsChanged();
		} else {
			System.err.println("Unable to undo move line point, newpoint is missing from pointlist, someone probably swapped it already!");
		}
	}

}
