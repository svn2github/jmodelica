package org.jastadd.ed.core.model;

import java.util.Stack;

import org.eclipse.core.resources.IFile;

public interface IOutlineCache {
	/**
	 * Create an {@link ITaskObject} caching the children of the specified node.
	 * 
	 * @param nodePath
	 * @param node
	 * @param task
	 *            org.jmodelica.ide.outline.OutlineUpdateWorker.ChildrenTask
	 */
	void fetchChildren(Stack<IASTPathPart> astPath,
			Object childrenTask);

	int getListenerID();
	
	/**
	 * Set the file for this content provider. Registers as listener against file depending on parameter.
	 * @param file The file this content provider listens to.
	 * @param registerASTListener If true, register as listener against file
	 */
	void setFile(IFile file, boolean registerASTListener);
}