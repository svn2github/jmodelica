package org.jmodelica.ide.compiler;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jmodelica.icons.coord.Placement;

public class ModificationJob implements IJobObject {

	private int jobType;
	private IFile file;
	private String className;
	private String componentName;
	private Placement placement;
	private String sourceDiagramName;
	private String targetDiagramName;
	private Stack<String> classASTPath;
	private Stack<String> modifyNodeASTPath;
	private String renameName;

	// Used to specify changesets for undo in graphical editor (e.g. to restore
	// all connections of a removed component).
	private int changeSetId = 0;

	/**
	 * node = the node in src tree to remove
	 * 
	 * @param jobType
	 * @param file
	 * @param node
	 */
	public ModificationJob(int jobType, IFile file,
			Stack<String> modifyNodeASTPath) {
		this.jobType = jobType;
		this.file = file;
		this.modifyNodeASTPath = modifyNodeASTPath;
	}

	public ModificationJob(int jobType, IFile file,
			Stack<String> modifyNodeASTPath, String renameName) {
		this(jobType, file, modifyNodeASTPath);
		this.renameName = renameName;
	}

	public ModificationJob(int jobType, IFile file,
			Stack<String> modifyNodeASTPath, Stack<String> classASTPath) {
		this(jobType, file, modifyNodeASTPath);
		this.classASTPath = classASTPath;
	}

	public ModificationJob(int jobType, IFile file, Stack<String> classASTPath,
			String className, String componentName, Placement placement) {
		this.jobType = jobType;
		this.file = file;
		this.classASTPath = classASTPath;
		this.className = className;
		this.componentName = componentName;
		this.placement = placement;
	}

	public ModificationJob(int jobType, IFile file, String sourceDiagramName,
			String targetdiagramName, Stack<String> classASTPath) {
		this.jobType = jobType;
		this.file = file;
		this.sourceDiagramName = sourceDiagramName;
		this.targetDiagramName = targetdiagramName;
		this.classASTPath = classASTPath;
	}

	public Stack<String> getModifyNodeASTPath() {
		return modifyNodeASTPath;
	}

	public Stack<String> getClassASTPath() {
		return classASTPath;
	}

	public String getSourceDiagramName() {
		return sourceDiagramName;
	}

	public String getTargetDiagramName() {
		return targetDiagramName;
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

	@Override
	public void doJob() {
		System.out.println("ModificationJob->doJob()");
		new ModelicaASTRegistryVisitor(this);
	}

	@Override
	public int getPriority() {
		return IJobObject.PRIORITY_HIGH;
	}

	public String getRenameName() {
		return renameName;
	}

	@Override
	public int getListenerID() {
		return 0;
	}

	public void setChangeSetId(int changeSetId) {
		this.changeSetId = changeSetId;
	}

	public int getChangeSetId() {
		return changeSetId;
	}
}