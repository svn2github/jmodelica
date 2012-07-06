package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.Connection;
import org.jmodelica.icons.coord.Point;

public abstract class DeleteBendpointCommand extends Command {
	
	private Connection connection;
	private int index;
	private Point oldPoint;
	
	public DeleteBendpointCommand(Connection connection) {
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
		index = connection.getPoints().indexOf(oldPoint);
		if (index != -1) {
			connection.getPoints().remove(index);
			connection.pointsChanged();
		} else {
			System.err.println("Oldpoint is missing from pointlist, someone probably swapped it already!");
		}
	}
	
	@Override
	public void undo() {
		if (index != -1) {
			connection.getPoints().add(index, oldPoint);
			connection.pointsChanged();
		} else {
			System.err.println("Index is invalid, someone probably changed the list already!");
		}
	}
	
}
