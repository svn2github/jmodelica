package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.primitives.GraphicItem;

public class RotateGraphicItemCommand extends Command {
	
	private GraphicItem item;
	private double angle;
	
	public RotateGraphicItemCommand(GraphicItem item, double angle) {
		this.item = item;
		this.angle = angle;
	}
	
	@Override
	public boolean canExecute() {
		return true;
	}
	
	@Override
	public void execute() {
		redo();
	}
	
	@Override
	public void redo() {
		item.setRotation(item.getRotation() + angle);
	}
	
	@Override
	public void undo() {
		item.setRotation(item.getRotation() - angle);
	}
}
