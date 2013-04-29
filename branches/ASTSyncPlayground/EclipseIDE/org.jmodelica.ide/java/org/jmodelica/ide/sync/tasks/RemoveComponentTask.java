package org.jmodelica.ide.sync.tasks;

import java.util.Stack;

import org.eclipse.core.resources.IFile;

public class RemoveComponentTask extends AbstractModificationTask {

	private Stack<String> componentASTPath;
	private Stack<String> classASTPath;

	public RemoveComponentTask(IFile file, Stack<String> componentASTPath,
			Stack<String> classASTPath, int undoActionId) {
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

	public Stack<String> getComponentASTPath() {
		return componentASTPath;
	}

	public Stack<String> getClassASTPath() {
		return classASTPath;
	}
}