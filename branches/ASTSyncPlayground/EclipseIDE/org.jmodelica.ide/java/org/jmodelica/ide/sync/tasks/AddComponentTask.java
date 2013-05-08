package org.jmodelica.ide.sync.tasks;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.ide.sync.ASTPathPart;

public class AddComponentTask extends AbstractModificationTask {

	private Stack<ASTPathPart> classASTPath;
	private Placement placement;
	private String componentName;
	private String className;

	public AddComponentTask(IFile file, Stack<ASTPathPart> classASTPath,
			String className, String componentName, Placement placement,
			int undoActionId) {
		super(file, undoActionId);
		this.classASTPath = classASTPath;
		this.className = className;
		this.componentName = componentName;
		this.placement = placement;
	}

	@Override
	public int getJobType() {
		return ITaskObject.ADD_COMPONENT;
	}

	@Override
	public int getListenerID() {
		return 0;
	}

	public Placement getPlacement() {
		return placement;
	}

	public String getComponentName() {
		return componentName;
	}

	public String getClassName() {
		return className;
	}

	public Stack<ASTPathPart> getClassASTPath() {
		return classASTPath;
	}
}