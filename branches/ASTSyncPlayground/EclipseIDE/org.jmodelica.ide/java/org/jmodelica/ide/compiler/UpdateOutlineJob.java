package org.jmodelica.ide.compiler;

import java.util.Stack;

import org.jastadd.ed.core.model.IASTChangeListener;

public class UpdateOutlineJob implements IJobObject {
	private Stack<String> changedPath;
	private IASTChangeListener listener;
	private int outlineID;

	public UpdateOutlineJob(IASTChangeListener listener,
			Stack<String> changedPath, int outlineID) {
		this.changedPath = changedPath;
		this.listener = listener;
		this.outlineID = outlineID;
	}

	public int getPriority() {
		return IJobObject.PRIORITY_LOW;
	}

	@Override
	public int getListenerID() {
		return outlineID;
	}

	@Override
	public void doJob() {
		listener.astChanged(null);
	}

	public Stack<String> getChangedPath() {
		return changedPath;
	}
}
