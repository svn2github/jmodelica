package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.Connection;
import org.jmodelica.icons.coord.Point;

public abstract class CreateBendpointCommand extends Command {
	
	private Connection connection;
	private Point newPoint;
	private int index;
	
	public CreateBendpointCommand(Connection connection) {
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
		if (connection.getPoints().size() <= index)
			System.err.println("Index is out of bounds someone probably changed it already!");
		connection.getPoints().add(index, newPoint);
		connection.pointsChanged();
	}
	
	@Override
	public void undo() {
		int index = connection.getPoints().indexOf(newPoint);
		if (index != -1) {
			connection.getPoints().remove(index);
			connection.pointsChanged();
		} else {
			System.err.println("Newpoint is missing from pointlist, someone probably swapped it already!");
		}
	}
	
}
