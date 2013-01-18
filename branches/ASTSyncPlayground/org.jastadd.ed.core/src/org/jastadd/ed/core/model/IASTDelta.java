package org.jastadd.ed.core.model;

import org.jastadd.ed.core.model.node.IASTNode;

public interface IASTDelta {
	
	// Kind flags
	public static final int NO_CHANGE = 0;
	public static final int ADDED = 0x2;
	public static final int REMOVED = 0x4;
	public static final int CHANGED = 0x8;
	
	// Change flags
	public static final int CONTENT = 0x100;
	public static final int TYPE = 0x8000;
	public static final int REPLACED = 0x40000;
	public static final int CHILD_CHANGED = 0x200000;
	
	public int getKind();	
	
	public int getFlags();
	
	/**
	 * Returns the corresponding AST node
	 * @return the AST, or null if this is the workspace delta node
	 */
	public IASTNode getASTNode();
	
	public IASTDelta[] getAffectedChildren();
		
	public void accept(IASTDeltaVisitor visitor);
}
