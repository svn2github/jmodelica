package org.jmodelica.ide.sync.tasks;

import java.util.Stack;

import org.jastadd.ed.core.model.ASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.sync.ASTPathPart;

public class NotifyGraphicalTask implements ITaskObject {
	private Stack<ASTPathPart> changedPath;
	private IASTChangeListener listener;
	private int graphicalEditorID;
	private int astChangeEventType;

	public NotifyGraphicalTask(int astChangeEventType,
			IASTChangeListener listener, Stack<ASTPathPart> changedPath,
			int graphicalEditorID) {
		this.astChangeEventType = astChangeEventType;
		this.changedPath = changedPath;
		this.listener = listener;
		this.graphicalEditorID = graphicalEditorID;
	}

	public int getJobPriority() {
		return ITaskObject.PRIORITY_MEDIUM;
	}

	@Override
	public int getListenerID() {
		return graphicalEditorID;
	}

	@Override
	public void doJob() {
		ASTChangeEvent event = new ASTChangeEvent(astChangeEventType,
				IASTChangeEvent.FILE_LEVEL);
		listener.astChanged(event);
	}

	public Stack<ASTPathPart> getChangedPath() {
		return changedPath;
	}

	@Override
	public int getJobType() {
		return ITaskObject.UPDATE;
	}
}