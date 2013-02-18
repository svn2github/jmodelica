package org.jmodelica.ide.compiler;

import org.eclipse.core.resources.IFile;
import org.jmodelica.modelica.compiler.ASTNode;

public class JobObject {
	public static final int REMOVE_INSTNODE = 1;
	public static final int ADD_NODE = 2;
	public static final int RENAME_NODE = 3;

	private int jobType;
	private IFile file;
	private ASTNode<?> instNode;

	/**
	 * node = the node in src tree to remove
	 * 
	 * @param jobType
	 * @param file
	 * @param node
	 */
	public JobObject(int jobType, IFile file, ASTNode<?> node) {
		this.jobType = jobType;
		this.file = file;
		this.instNode = node;
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
}
