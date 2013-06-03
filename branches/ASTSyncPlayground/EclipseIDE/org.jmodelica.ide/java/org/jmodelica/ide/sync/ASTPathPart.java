package org.jmodelica.ide.sync;

import org.jastadd.ed.core.model.IASTPathPart;

public class ASTPathPart implements IASTPathPart {
	private String id;
	private int index;

	public ASTPathPart(String id, int index) {
		this.id = id;
		this.index = index;
	}

	public int index() {
		return index;
	}

	public String id() {
		return id;
	}
}