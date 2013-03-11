package org.jmodelica.ide.compiler;

import java.util.Stack;

import org.jastadd.ed.core.model.IASTChangeListener;

public class UpdateOutlineJob implements IJobObject {
	private Stack<Integer> changedPath;
	private IASTChangeListener listener;

	public UpdateOutlineJob(IASTChangeListener listener,
			Stack<Integer> changedPath) {
		this.changedPath = changedPath;
		this.listener = listener;
	}

	public int getPriority() {
		return IJobObject.PRIORITY_LOW;
	}

	@Override
	public void doJob() {
		System.out.println("UpdateOutlineJob->doJob()");
		listener.astChanged(null);
	}

	public Stack<Integer> getChangedPath() {
		return changedPath;
	}
}
