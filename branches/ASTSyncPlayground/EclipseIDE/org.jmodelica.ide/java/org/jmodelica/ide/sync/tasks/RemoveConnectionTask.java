package org.jmodelica.ide.sync.tasks;

import java.util.Stack;

import org.eclipse.core.resources.IFile;

public class RemoveConnectionTask extends AbstractModificationTask {

	private Stack<String> classASTPath;
	private Stack<String> connectClauseASTPath;

	public RemoveConnectionTask(IFile file, Stack<String> classASTPath,
			Stack<String> connectClauseASTPath, int undoActionId) {
		super(file, undoActionId);
		this.classASTPath = classASTPath;
		this.connectClauseASTPath = connectClauseASTPath;
	}

	@Override
	public int getJobType() {
		return ITaskObject.REMOVE_CONNECTCLAUSE;
	}

	/**
	 * We want to make sure we delete Connections before Components.
	 */
	@Override
	public int getJobPriority(){
		return ITaskObject.PRIORITY_HIGHEST;
	}
	
	public Stack<String> getConnectionClauseASTPath() {
		return connectClauseASTPath;
	}

	public Stack<String> getClassASTPath() {
		return classASTPath;
	}
}