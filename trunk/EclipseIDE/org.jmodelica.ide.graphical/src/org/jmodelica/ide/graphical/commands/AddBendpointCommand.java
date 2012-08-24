package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.ide.graphical.proxy.ConnectionProxy;

public abstract class AddBendpointCommand extends Command {

	private ConnectionProxy connection;
	private Point newPoint;
	private int index;

	public AddBendpointCommand(ConnectionProxy connection) {
		this.connection = connection;
		setLabel("add bendpoint");
	}

	protected abstract Point calculateNewPoint();

	protected abstract int calculateIndex();

	@Override
	public void execute() {
		index = calculateIndex();
		newPoint = calculateNewPoint();
		redo();
	}

	@Override
	public void redo() {
		Line line = connection.getLine();
		if (line == null) {
			System.err.println("Unable to redo add line point, connection not found!");
			return;
		}
		if (line.getPoints().size() <= index)
			System.err.println("Unable to redo add line point, index is out of bounds someone probably changed it already!");
		line.getPoints().add(index, newPoint);
		line.pointsChanged();
	}

	@Override
	public void undo() {
		Line line = connection.getLine();
		if (line == null) {
			System.err.println("Unable to undo add line point, connection not found!");
			return;
		}
		int index = line.getPoints().indexOf(newPoint);
		if (index != -1) {
			line.getPoints().remove(index);
			line.pointsChanged();
		} else {
			System.err.println("Unable to undo add line point, newpoint is missing from pointlist, someone probably swapped it already!");
		}
	}

}
