package org.jmodelica.ide.compiler;

import org.eclipse.core.resources.IFile;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.modelica.compiler.ASTNode;

public class ModificationJob implements IJobObject {

	private int jobType;
	private IFile file;
	private ASTNode<?> instNode;
	private String className;
	private String componentName;
	private Placement placement;

	/**
	 * node = the node in src tree to remove
	 * 
	 * @param jobType
	 * @param file
	 * @param node
	 */
	public ModificationJob(int jobType, IFile file, ASTNode<?> node) {
		this.jobType = jobType;
		this.file = file;
		this.instNode = node;
	}

	public ModificationJob(int jobType, IFile file, ASTNode<?> node,
			String className, String componentName, Placement placement) {
		this.jobType = jobType;
		this.file = file;
		this.instNode = node;
		this.className = className;
		this.componentName = componentName;
		this.placement = placement;
	}

	public Placement getPlacement() {
		return placement;
	}

	public String getClassName() {
		return className;
	}

	public String getComponentName() {
		return componentName;
	}

	public int getJobType() {
		return jobType;
	}

	public IFile getFile() {
		return file;
	}

	public ASTNode<?> getNode() {
		return instNode;
	}

	@Override
	public void doJob() {
		new ModelicaASTRegistryVisitor(this);
	}

	@Override
	public int getPriority() {
		return IJobObject.PRIORITY_HIGH;
	}

}
