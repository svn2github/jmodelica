package org.jmodelica.ide.sync.tasks;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jmodelica.ide.sync.ASTPathPart;

public class RemoveComponentTask extends AbstractModificationTask {

	private Stack<ASTPathPart> componentASTPath;
	private Stack<ASTPathPart> classASTPath;

	public RemoveComponentTask(IFile file, Stack<ASTPathPart> componentASTPath,
			Stack<ASTPathPart> classASTPath, int undoActionId) {
		super(file, undoActionId);
		this.componentASTPath = componentASTPath;
		this.classASTPath = classASTPath;
	}

	@Override
	public int getJobType() {
		return ITaskObject.REMOVE_COMPONENT;
	}

	@Override
	public int getListenerID() {
		return 0;
	}

	public Stack<ASTPathPart> getComponentASTPath() {
		return componentASTPath;
	}

	public Stack<ASTPathPart> getClassASTPath() {
		return classASTPath;
	}
}