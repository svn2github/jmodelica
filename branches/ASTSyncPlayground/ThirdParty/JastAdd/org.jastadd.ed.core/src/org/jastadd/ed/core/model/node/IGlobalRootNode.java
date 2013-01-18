package org.jastadd.ed.core.model.node;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;

public interface IGlobalRootNode extends IASTNode {
 
	/**
	 * Lookup a file entry enclosed by the given project
	 * @param file The file to look up the AST for
	 * @return The found node, or null if the lookup was unsuccessful
	 */
	public java.util.List<ILocalRootNode> lookupFileNode(IFile file);
	
	public ILocalRootNode[] lookupAllFileNodes();
	
	public IProject getProject();

	/** 
	 * Performs a full flush of attribute values cached in the tree
	 */
	//public void fullFlush();

	/** 
	 * Adds a new local root node to the tree
	 * @param newNode The local root to add 
	 */
	public void addFileNode(ILocalRootNode newNode);

}
