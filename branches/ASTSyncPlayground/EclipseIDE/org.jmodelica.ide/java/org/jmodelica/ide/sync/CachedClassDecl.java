package org.jmodelica.ide.sync;

import org.jastadd.ed.core.model.IOutlineCache;
import org.jmodelica.modelica.compiler.ClassDecl;

public class CachedClassDecl extends CachedASTNode {
	private String qualifiedName;

	public CachedClassDecl(ClassDecl cd, Object parent, IOutlineCache cache) {
		super(cd, parent, cache);
		this.qualifiedName = cd.qualifiedName();
	}

	public String qualifiedName() {
		return qualifiedName;
	}
}