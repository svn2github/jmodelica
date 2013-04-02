package org.jmodelica.ide.helpers;

import java.util.Stack;

import org.jmodelica.ide.compiler.IJobObject;

public interface IOutlineCache {
	/**
	 * Create an {@link IJobObject} caching the children of the specified node.
	 * 
	 * @param nodePath
	 * @param node
	 * @param task org.jmodelica.ide.outline.OutlineUpdateWorker.ChildrenTask
	 */
	void fetchChildren(Stack<String> astPath, ICachedOutlineNode node,
			Object childrenTask);

}
