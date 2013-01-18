package org.jastadd.ed.core.model;

import org.jastadd.ed.core.model.node.IASTNode;

public class ASTDelta implements IASTDelta {

	protected IASTNode node;
	protected IASTDelta[] children;

	protected int status;
	protected static int KIND_MASK = 0xFF;
	
	
	public ASTDelta(IASTNode node, IASTDelta[] children) {
		this.node = node;
		this.children = children;
	}
	
	@Override
	public int getKind() {
		return status & KIND_MASK;
	}

	@Override
	public int getFlags() {
		return status & ~KIND_MASK;
	}

	@Override
	public IASTNode getASTNode() {
		return node;
	}

	@Override
	public IASTDelta[] getAffectedChildren() {
		return getAffectedChildren(ADDED | REMOVED | CHANGED);
	}
	
	@Override
	public void accept(IASTDeltaVisitor visitor) {
		if (!visitor.visit(this))
			return;
		for (int i = 0; i < children.length; i++) {
			IASTDelta childDelta = children[i];
			childDelta.accept(visitor);
		}
	}
	
	public IASTDelta[] getAffectedChildren(int kindMask) {
		
		int numChildren = children.length;
		if (numChildren == 0) 
			return children; // All match
		
		int matching = 0;
		for (int i = 0; i < numChildren; i++) {
			if ((children[i].getKind() & kindMask) == 0)
				continue; // Wrong kind
			matching++;
		}
		// If all match, use arraycopy
		if (matching == numChildren) {
			IASTDelta[] result = new IASTDelta[children.length];
			System.arraycopy(children, 0, result, 0, children.length);
			return result;
		}
		// create an array an copy if smaller
		IASTDelta[] result = new IASTDelta[matching];
		int nextIndex = 0;
		for (int i = 0; i < numChildren; i++) {
			if ((children[i].getKind() & kindMask) == 0) 
				continue;
			result[nextIndex++] = children[i];
		}
		return result;		
	}

	protected void setStatus(int status) {
		this.status = status;
	}


}
