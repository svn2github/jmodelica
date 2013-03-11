package org.jmodelica.ide.graphical.proxy.cache;

import org.jmodelica.modelica.compiler.InstClassDecl;

public class CachedInstClassDecl extends CachedInstNode {
	private String syncGetclassIconName;
	private String syncQualifiedName;
	private String definitionKey;

	public CachedInstClassDecl(InstClassDecl icd) {
		super(icd);
		//System.out.println("Created InstClassDeclCached...");
		syncGetclassIconName = icd.syncGetClassIconName();
		syncQualifiedName = icd.syncQualifiedName();
		definitionKey=icd.getDefinition().lookupKey();
	}

	public String syncGetClassIconName() {
		return syncGetclassIconName;
	}

	public String syncQualifiedName() {
		return syncQualifiedName;
	}

	public String getDefinitionKey() {
		return definitionKey;
	}
}
