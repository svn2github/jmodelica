package org.jmodelica.ide.sync.tasks;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTPathPart;
import org.jastadd.ed.core.model.ITaskObject;

public class RemoveConnectionTask extends AbstractModificationTask {

	private Stack<IASTPathPart> classASTPath;
	private Stack<IASTPathPart> connectClauseASTPath;

	public RemoveConnectionTask(IFile file, Stack<IASTPathPart> classASTPath,
			Stack<IASTPathPart> connectClauseASTPath, int undoActionId) {
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
	public int getJobPriority() {
		return ITaskObject.PRIORITY_HIGHEST;
	}

	public Stack<IASTPathPart> getConnectionClauseASTPath() {
		return connectClauseASTPath;
	}

	public Stack<IASTPathPart> getClassASTPath() {
		return classASTPath;
	}
}