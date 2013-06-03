package org.jmodelica.ide.sync.tasks;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTPathPart;
import org.jastadd.ed.core.model.ITaskObject;

public class AddConnectionTask extends AbstractModificationTask {

	private Stack<IASTPathPart> classASTPath;
	private String targetDiagramName;
	private String sourceDiagramName;

	public AddConnectionTask(IFile file, Stack<IASTPathPart> classASTPath,
			String sourceDiagramName, String targetDiagramName, int undoActionId) {
		super(file, undoActionId);
		this.classASTPath = classASTPath;
		this.targetDiagramName = targetDiagramName;
		this.sourceDiagramName = sourceDiagramName;
		this.undoActionId = undoActionId;
	}

	@Override
	public int getJobType() {
		return ITaskObject.ADD_CONNECTCLAUSE;
	}

	public Stack<IASTPathPart> getClassASTPath() {
		return classASTPath;
	}

	public String getTargetDiagramName() {
		return targetDiagramName;
	}

	public String getSourceDiagramName() {
		return sourceDiagramName;
	}
}