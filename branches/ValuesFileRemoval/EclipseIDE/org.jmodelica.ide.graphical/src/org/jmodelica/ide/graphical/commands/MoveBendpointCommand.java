package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.Connection;
import org.jmodelica.icons.coord.Point;

public abstract class MoveBendpointCommand extends Command {
	
	private Connection connection;
	private Point newPoint;
	private Point oldPoint;
	
	public MoveBendpointCommand(Connection connection) {
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
		int index = connection.getPoints().indexOf(oldPoint);
		if (index != -1) {
			connection.getPoints().set(index, newPoint);
			connection.pointsChanged();
		} else {
			System.err.println("Oldpoint is missing from pointlist, someone probably swapped it already!");
		}
	}
	
	@Override
	public void undo() {
		int index = connection.getPoints().indexOf(newPoint);
		if (index != -1) {
			connection.getPoints().set(index, oldPoint);
			connection.pointsChanged();
		} else {
			System.err.println("Newpoint is missing from pointlist, someone probably swapped it already!");
		}
	}
	
}
