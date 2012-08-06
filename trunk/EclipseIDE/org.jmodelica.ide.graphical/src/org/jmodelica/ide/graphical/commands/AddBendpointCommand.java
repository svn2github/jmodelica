package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.primitives.Line;

public abstract class AddBendpointCommand extends Command {

	private Line line;
	private Point newPoint;
	private int index;

	public AddBendpointCommand(Line line) {
		this.line = line;
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
		if (line.getPoints().size() <= index)
			System.err.println("Index is out of bounds someone probably changed it already!");
		line.getPoints().add(index, newPoint);
		line.pointsChanged();
	}

	@Override
	public void undo() {
		int index = line.getPoints().indexOf(newPoint);
		if (index != -1) {
			line.getPoints().remove(index);
			line.pointsChanged();
		} else {
			System.err.println("Newpoint is missing from pointlist, someone probably swapped it already!");
		}
	}

}
