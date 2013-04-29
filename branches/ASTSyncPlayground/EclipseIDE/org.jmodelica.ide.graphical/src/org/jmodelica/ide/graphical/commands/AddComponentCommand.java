package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.ide.graphical.proxy.AbstractDiagramProxy;
import org.jmodelica.ide.sync.ASTRegTaskBucket;
import org.jmodelica.ide.sync.UniqueIDGenerator;
import org.jmodelica.ide.sync.tasks.ITaskObject;
import org.jmodelica.ide.sync.tasks.UndoTask;

public class AddComponentCommand extends Command {

	private AbstractDiagramProxy diagram;
	private String className;
	private Placement placement;
	private int myId;

	public AddComponentCommand(AbstractDiagramProxy diagram, String className,
			Placement placement) {
		myId = UniqueIDGenerator.getInstance().getChangeSetID();
		this.diagram = diagram;
		this.className = className;
		this.placement = placement;
		setLabel("add component");
	}

	@Override
	public void execute() {
		diagram.addComponent(className, placement, myId);
	}

	@Override
	public void redo() {
		UndoTask job = new UndoTask(ITaskObject.UNDO_REMOVE,
				myId);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	public void undo() {
		UndoTask job = new UndoTask(
				ITaskObject.UNDO_ADD, myId);
		ASTRegTaskBucket.getInstance().addTask(job);
	}
}
