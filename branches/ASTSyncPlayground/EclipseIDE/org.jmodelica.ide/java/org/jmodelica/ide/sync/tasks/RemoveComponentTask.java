package org.jmodelica.ide.sync.tasks;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTPathPart;
import org.jastadd.ed.core.model.ITaskObject;

public class RemoveComponentTask extends AbstractModificationTask {

	private Stack<IASTPathPart> componentASTPath;
	private Stack<IASTPathPart> classASTPath;

	public RemoveComponentTask(IFile file, Stack<IASTPathPart> componentASTPath,
			Stack<IASTPathPart> classASTPath, int undoActionId) {
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

	public Stack<IASTPathPart> getComponentASTPath() {
		return componentASTPath;
	}

	public Stack<IASTPathPart> getClassASTPath() {
		return classASTPath;
	}
}