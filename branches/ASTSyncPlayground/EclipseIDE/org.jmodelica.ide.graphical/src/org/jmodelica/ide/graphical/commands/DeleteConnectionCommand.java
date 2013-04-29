package org.jmodelica.ide.graphical.commands;

import org.eclipse.gef.commands.Command;
import org.jmodelica.ide.graphical.proxy.AbstractDiagramProxy;
import org.jmodelica.ide.graphical.proxy.ConnectionProxy;
import org.jmodelica.ide.sync.ASTRegTaskBucket;
import org.jmodelica.ide.sync.UniqueIDGenerator;
import org.jmodelica.ide.sync.tasks.ITaskObject;
import org.jmodelica.ide.sync.tasks.UndoTask;

public class DeleteConnectionCommand extends Command {
	AbstractDiagramProxy proxy;
	ConnectionProxy connection;
	private String sourceDiagramName;
	private String targetDiagramName;
	private int myId;

	public DeleteConnectionCommand(ConnectionProxy connection) {
		myId = UniqueIDGenerator.getInstance().getChangeSetID();
		this.connection = connection;
		this.sourceDiagramName = connection.getSource().buildDiagramName();
		this.targetDiagramName = connection.getTarget().buildDiagramName();
		System.out.println(sourceDiagramName + "--" + targetDiagramName);
		proxy = connection.getProxy();
		setLabel("remove connection");
	}

	@Override
	public void execute() {
		connection.disconnect(myId);
	}

	@Override
	public void undo() {
		UndoTask job = new UndoTask(ITaskObject.UNDO_REMOVE, myId);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	public void redo() {
		UndoTask job = new UndoTask(ITaskObject.UNDO_ADD, myId);
		ASTRegTaskBucket.getInstance().addTask(job);
	}
}
