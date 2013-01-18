package org.jastadd.ed.core.model.node;

import org.eclipse.core.resources.IFile;

public interface ILocalRootNode extends IASTNode {
	
	public boolean correspondsTo(ILocalRootNode node);
	
	public void setFile(IFile file);
	
	public IFile getFile();

	/** 
	 * Removed this local root node from its surrounding tree
	 */
	public void discardFromTree();

	/** 
	 * Checks whether the given new local root node should update this node.
	 * The given node should already correspond to this node.
	 * @param newNode The new node to possibly update with
	 * @return true if the new node should replace this one, otherwise false
	 */
	public boolean shouldBeUpdatedWith(ILocalRootNode newNode);

	/** 
	 * Updates this local root node with a new node
	 * @param newNode The new node to update with
	 */
	public void updateWith(ILocalRootNode newNode);
	
}
