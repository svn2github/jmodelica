package org.jastadd.ed.core.model;

import java.util.ArrayList;

import org.jastadd.ed.core.model.node.IASTNode;

public interface IASTChangeEvent {

	public static final int POST_UPDATE = 1;
	public static final int POST_REMOVE = 2;
	public static final int POST_ADDED = 2;
	public static final int POST_RENAME = 5;

	public static final int PROJECT_LEVEL = 3;
	public static final int FILE_LEVEL = 4;

	/**
	 * Returns the AST delta, rooted at the project, or file level if its a
	 * single file.
	 * 
	 * @return the AST delta, or null if not applicable
	 */
	public IASTDelta getDelta();

	/**
	 * Returns the AST (node) in question. This will always be the previous node
	 * on the tree which has either been removed or updated.
	 * 
	 * @return the AST
	 */
	public IASTNode getChangedNode();

	/**
	 * Returns the type of event being reported.
	 * 
	 * @return one of the event type constants
	 * @see #POST_UPDATE
	 * @see #PRE_REMOVE
	 */
	public int getType();

	/**
	 * Returns on which AST level the event has occurred
	 * 
	 * @return on of the level constants
	 * @see #PROJECT_LEVEL
	 * @see #FILE_LEVEL
	 */
	public int getLevel();

	public ArrayList<String> getChangedPath();
}
