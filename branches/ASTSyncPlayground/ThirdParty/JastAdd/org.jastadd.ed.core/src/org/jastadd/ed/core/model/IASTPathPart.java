package org.jastadd.ed.core.model;

/**
 * Contains an AST node identifier and the nodes child index at its parent
 * 
 */
public interface IASTPathPart {
	/**
	 * The node child index at its parent
	 * 
	 * @return
	 */
	int index();

	/**
	 * The unique node identifier
	 * 
	 * @return
	 */
	String id();
}
