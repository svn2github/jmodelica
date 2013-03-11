package org.jmodelica.ide.graphical.proxy.cache;

import org.jmodelica.icons.coord.Placement;
import org.jmodelica.modelica.compiler.InstComponentDecl;

public class CachedInstComponentDecl extends CachedInstNode {
	private String syncName;
	private String syncQualifiedName;
	private boolean syncIsConnector;
	private boolean syncIsIconRenderable;
	private Placement syncGetPlacement;
	private boolean syncIsPrimitive;
	private boolean syncIsParameter;

	public CachedInstComponentDecl(InstComponentDecl icd) {
		super(icd);
		//System.out.println("Created InstComponentDeclCached...");
		syncName = icd.syncName();
		syncQualifiedName = icd.syncQualifiedName();
		syncIsConnector = icd.syncIsConnector();
		syncIsIconRenderable = icd.syncIsIconRenderable();
		syncGetPlacement = icd.syncGetPlacement();
		syncIsPrimitive = icd.syncIsPrimitive();
		syncIsParameter = icd.syncIsParameter();
	}

	public String syncName() {
		return syncName;
	}

	public String syncQualifiedName() {
		return syncQualifiedName;
	}

	public boolean syncIsConnector() {
		return syncIsConnector;
	}

	public boolean syncIsIconRenderable() {
		return syncIsIconRenderable;
	}

	public Placement syncGetPlacement() {
		return syncGetPlacement;
	}

	public boolean syncIsPrimitive() {
		return syncIsPrimitive;
	}

	public boolean syncIsParameter() {
		return syncIsParameter;
	}
}
