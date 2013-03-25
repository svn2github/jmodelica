package org.jmodelica.ide.outline.cache;

import org.jmodelica.modelica.compiler.ClassDecl;

public class CachedClassDecl extends CachedASTNode {
	private String qualifiedName;
	private String name;

	public CachedClassDecl(ClassDecl cd, Object parent,
			AbstractOutlineCache cache) {
		super(cd, parent, cache);
		this.qualifiedName = cd.qualifiedName();
		this.name = cd.name();
	}

	public String name() {
		return name;
	}

	public String qualifiedName() {
		return qualifiedName;
	}
}
