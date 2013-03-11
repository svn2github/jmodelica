package org.jmodelica.ide.compiler;

import java.util.Stack;

import org.jastadd.ed.core.model.IASTChangeListener;

public class UpdateGraphicalJob implements IJobObject {
	private Stack<Integer> changedPath;
	private IASTChangeListener listener;

	public UpdateGraphicalJob(IASTChangeListener listener,
			Stack<Integer> changedPath) {
		this.changedPath = changedPath;
		this.listener = listener;
	}

	public int getPriority() {
		return IJobObject.PRIORITY_MEDIUM;
	}

	@Override
	public void doJob() {
		System.out.println("UpdateGraphicalJob->doJob()");
		listener.astChanged(null);
	}

	public Stack<Integer> getChangedPath() {
		return changedPath;
	}
}