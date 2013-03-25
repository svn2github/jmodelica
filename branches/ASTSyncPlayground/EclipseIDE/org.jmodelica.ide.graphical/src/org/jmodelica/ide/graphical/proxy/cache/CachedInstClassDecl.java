package org.jmodelica.ide.graphical.proxy.cache;

import java.util.Stack;

import org.jmodelica.modelica.compiler.InstClassDecl;

public class CachedInstClassDecl extends CachedInstNode {
	private String syncGetclassIconName;
	private String syncQualifiedName;
	private Stack<String> classASTPath;

	public CachedInstClassDecl(InstClassDecl icd) {
		super(icd);
		// System.out.println("Created InstClassDeclCached...");
		syncGetclassIconName = icd.syncGetClassIconName();
		syncQualifiedName = icd.syncQualifiedName();
	}

	public String syncGetClassIconName() {
		return syncGetclassIconName;
	}

	public String syncQualifiedName() {
		return syncQualifiedName;
	}
	
	public void setClassASTPath(Stack<String> classASTPath) {
		this.classASTPath = classASTPath;
	}

	public Stack<String> getClassASTPath() {
		return classASTPath;
	}
}
