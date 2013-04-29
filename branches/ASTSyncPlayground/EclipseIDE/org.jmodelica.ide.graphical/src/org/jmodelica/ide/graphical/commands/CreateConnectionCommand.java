package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.ide.graphical.proxy.ConnectionProxy;
import org.jmodelica.ide.graphical.proxy.ConnectorProxy;
import org.jmodelica.ide.sync.ASTRegTaskBucket;
import org.jmodelica.ide.sync.UniqueIDGenerator;
import org.jmodelica.ide.sync.tasks.ITaskObject;
import org.jmodelica.ide.sync.tasks.UndoTask;

public abstract class CreateConnectionCommand extends Command {

	private ConnectorProxy source;
	private ConnectorProxy target;
	private int myId;

	public CreateConnectionCommand(ConnectorProxy source) {
		this.source = source;
		myId = UniqueIDGenerator.getInstance().getChangeSetID();
		setLabel("add connection");
	}

	public void setTarget(ConnectorProxy model) {
		target = model;
	}

	@Override
	public boolean canExecute() {
		if (target == null)
			return true;
		if (source == target) {
			return false;
		}
		for (ConnectionProxy con : source.getTargetConnections()) {
			if (con.getSource().equals(target)) {
				return false;
			}
		}
		for (ConnectionProxy con : source.getSourceConnections()) {
			if (con.getTarget().equals(target)) {
				return false;
			}
		}
		return true;
	}

	protected abstract void initConnection(ConnectionProxy connection);

	@Override
	public void execute() {
		source.getDiagram().addConnection(source.buildDiagramName(),
				target.buildDiagramName(), myId);
	}

	@Override
	public void redo() {
		UndoTask job = new UndoTask(ITaskObject.UNDO_REMOVE, myId);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	public void undo() {
		UndoTask job = new UndoTask(ITaskObject.UNDO_ADD, myId);
		ASTRegTaskBucket.getInstance().addTask(job);
	}
}
