package org.jmodelica.ide.sync.tasks;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jmodelica.icons.coord.Placement;

public class AddComponentTask extends AbstractModificationTask {

	private Stack<String> classASTPath;
	private Placement placement;
	private String componentName;
	private String className;

	public AddComponentTask(IFile file, Stack<String> classASTPath,
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

	public Stack<String> getClassASTPath() {
		return classASTPath;
	}
}