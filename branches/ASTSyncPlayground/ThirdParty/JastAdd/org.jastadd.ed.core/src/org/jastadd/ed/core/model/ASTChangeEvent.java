package org.jastadd.ed.core.model;

import java.util.ArrayList;

import org.jastadd.ed.core.model.node.IASTNode;
import org.jastadd.ed.core.model.IASTDelta;

/**
 * AST change events describe changes to ASTs. There are two types of AST change
 * events:
 * 
 * POST_UPDATE, PRE_REMOVE PROJECT_LEVEL, FILE_LEVEL
 * 
 * @author emma
 * 
 */
public class ASTChangeEvent implements IASTChangeEvent {

	protected IASTDelta delta;
	protected ArrayList<String> changedPath;
	protected IASTNode changedNode;
	protected int type;
	protected int level;

	public ASTChangeEvent(int type, int level, IASTNode changedNode,
			ArrayList<String> changedPath, IASTDelta delta) {
		this.type = type;
		this.level = level;
		this.changedNode = changedNode;
		this.changedPath = changedPath;
		this.delta = delta;
	}

	@Override
	public IASTDelta getDelta() {
		return delta;
	}

	@Override
	public IASTNode getChangedNode() {
		return changedNode;
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

	@Override
	public ArrayList<String> getChangedPath() {
		return changedPath;
	}

}
