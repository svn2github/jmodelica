package org.jmodelica.ide.graphical.proxy.cache;

import java.util.Stack;

import org.jmodelica.ide.sync.ASTPathPart;
import org.jmodelica.modelica.compiler.InstClassDecl;

public class CachedInstClassDecl extends CachedInstNode {
	private String syncGetclassIconName;
	private String syncQualifiedName;
	private Stack<ASTPathPart> classASTPath;

	public CachedInstClassDecl(InstClassDecl icd) {
		super(icd);
		syncGetclassIconName = icd.syncGetClassIconName();
		syncQualifiedName = icd.syncQualifiedName();
	}

	public String syncGetClassIconName() {
		return syncGetclassIconName;
	}

	public String syncQualifiedName() {
		return syncQualifiedName;
	}

	public void setClassASTPath(Stack<ASTPathPart> classASTPath) {
		this.classASTPath = classASTPath;
	}

	public Stack<ASTPathPart> getClassASTPath() {
		return classASTPath;
	}
}