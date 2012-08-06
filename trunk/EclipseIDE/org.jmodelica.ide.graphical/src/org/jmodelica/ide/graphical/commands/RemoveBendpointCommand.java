package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.primitives.Line;

public abstract class RemoveBendpointCommand extends Command {

	private Line line;
	private int index;
	private Point oldPoint;

	public RemoveBendpointCommand(Line line) {
		this.line = line;
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
		index = line.getPoints().indexOf(oldPoint);
		if (index != -1) {
			line.getPoints().remove(index);
			line.pointsChanged();
		} else {
			System.err.println("Oldpoint is missing from pointlist, someone probably swapped it already!");
		}
	}

	@Override
	public void undo() {
		if (index != -1) {
			line.getPoints().add(index, oldPoint);
			line.pointsChanged();
		} else {
			System.err.println("Index is invalid, someone probably changed the list already!");
		}
	}

}
