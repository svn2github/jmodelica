package org.jmodelica.ide.sync.tasks;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jmodelica.ide.sync.ASTPathPart;

public class RemoveConnectionTask extends AbstractModificationTask {

	private Stack<ASTPathPart> classASTPath;
	private Stack<ASTPathPart> connectClauseASTPath;

	public RemoveConnectionTask(IFile file, Stack<ASTPathPart> classASTPath,
			Stack<ASTPathPart> connectClauseASTPath, int undoActionId) {
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

	public Stack<ASTPathPart> getConnectionClauseASTPath() {
		return connectClauseASTPath;
	}

	public Stack<ASTPathPart> getClassASTPath() {
		return classASTPath;
	}
}