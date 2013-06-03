package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jastadd.ed.core.model.ITaskObject;
import org.jmodelica.ide.graphical.proxy.AbstractDiagramProxy;
import org.jmodelica.ide.graphical.proxy.ComponentProxy;
import org.jmodelica.ide.sync.ASTRegTaskBucket;
import org.jmodelica.ide.sync.UniqueIDGenerator;
import org.jmodelica.ide.sync.tasks.UndoTask;

public class DeleteComponentCommand extends Command {
	AbstractDiagramProxy proxy;
	private ComponentProxy component;
	private int myId;

	public DeleteComponentCommand(ComponentProxy component) {
		this.component = component;
		myId = UniqueIDGenerator.getInstance().getChangeSetID();
		setLabel("remove component");
	}

	@Override
	public void execute() {
		proxy = component.getDiagram();
		component.getDiagram().removeComponent(component, myId);
	}

	@Override
	public void redo() {
		UndoTask job = new UndoTask(ITaskObject.UNDO_ADD, myId);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	public void undo() {
		UndoTask job = new UndoTask(ITaskObject.UNDO_REMOVE, myId);
		ASTRegTaskBucket.getInstance().addTask(job);
	}
}
