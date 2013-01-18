package org.jastadd.ed.core.model;

import org.jastadd.ed.core.model.node.IASTNode;
import org.jastadd.ed.core.model.IASTDelta;

/**
 * AST change events describe changes to ASTs.
 * There are two types of AST change events:
 * 
 * POST_UPDATE, PRE_REMOVE
 * PROJECT_LEVEL, FILE_LEVEL
 * 
 * @author emma
 *
 */
public class ASTChangeEvent implements IASTChangeEvent {
	
	protected IASTDelta delta;
	protected IASTNode node;
	protected int type;
	protected int level;
	
	public ASTChangeEvent(int type, int level, IASTNode node, IASTDelta delta) {
		this.type = type;
		this.level = level;
		this.node = node;
		this.delta = delta;
	}

	@Override
	public IASTDelta getDelta() {
		return delta;
	}

	@Override
	public IASTNode getNode() {
		return node;
	}

	@Override
	public int getType() {
		return type;
	}

	@Override
	public int getLevel() {
		return level;
	}
	
	public void setDelta(IASTDelta value) {
		delta = value;
	}



}
