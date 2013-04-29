package org.jastadd.ed.core.model;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
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
	protected Stack<Integer> changedPath;
	protected IASTNode changedNode;
	protected int type;
	protected int level;
	protected IFile file;

	public ASTChangeEvent(int type, int level, IASTNode changedNode,
			Stack<Integer> changedPath, ASTDelta delta) {
		this(type, level);
		this.changedNode = changedNode;
		this.delta = delta;
		this.changedPath = changedPath;
	}

	public ASTChangeEvent(int type, int level) {
		this.type = type;
		this.level = level;
	}

	public ASTChangeEvent(IFile file, int type, int level) {
		this(type, level);
		this.file = file;
	}

	@Override
	public int getType() {
		return type;
	}

	@Override
	public int getLevel() {
		return level;
	}

	/**
	 * public void setDelta(IASTDelta value) { delta = value; }
	 */

	@Override
	public Stack<Integer> getChangedPath() {
		return changedPath;
	}

	@Override
	public IFile getFile() {
		return file;
	}

}
