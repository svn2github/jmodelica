package org.jmodelica.ide.compiler;

import java.util.Stack;

import org.jastadd.ed.core.model.IASTChangeListener;

public class UpdateGraphicalJob implements IJobObject {
	private Stack<String> changedPath;
	private IASTChangeListener listener;
	private int graphicalEditorID;

	public UpdateGraphicalJob(IASTChangeListener listener,
			Stack<String> changedPath, int graphicalEditorID) {
		this.changedPath = changedPath;
		this.listener = listener;
		this.graphicalEditorID = graphicalEditorID;
	}

	public int getPriority() {
		return IJobObject.PRIORITY_MEDIUM;
	}

	@Override
	public int getListenerID(){
		return graphicalEditorID;
	}
	
	@Override
	public void doJob() {
		System.out.println("UpdateGraphicalJob->doJob()");
		listener.astChanged(null);
	}

	public Stack<String> getChangedPath() {
		return changedPath;
	}
}