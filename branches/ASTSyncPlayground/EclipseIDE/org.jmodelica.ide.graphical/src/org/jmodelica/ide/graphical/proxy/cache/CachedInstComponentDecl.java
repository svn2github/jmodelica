package org.jmodelica.ide.graphical.proxy.cache;

import java.util.ArrayList;
import java.util.List;
import java.util.Stack;

import org.jmodelica.icons.coord.Placement;
import org.jmodelica.ide.compiler.ModelicaASTRegistry;
import org.jmodelica.modelica.compiler.InstComponentDecl;
import org.jmodelica.modelica.compiler.InstExtends;
import org.jmodelica.modelica.compiler.InstNode;
import org.jmodelica.modelica.compiler.InstPrimitive;

public class CachedInstComponentDecl extends CachedInstNode {
	private String syncName;
	private String syncQualifiedName;
	private boolean syncIsConnector;
	private boolean syncIsIconRenderable;
	private Placement syncGetPlacement;
	private boolean syncIsPrimitive;
	private boolean syncIsParameter;
	private Stack<String> astPath;
	private List<String[]> params;

	public CachedInstComponentDecl(InstComponentDecl icd) {
		super(icd);
		// System.out.println("Created InstComponentDeclCached...");
		syncName = icd.syncName();
		syncQualifiedName = icd.syncQualifiedName();
		syncIsConnector = icd.syncIsConnector();
		syncIsIconRenderable = icd.syncIsIconRenderable();
		syncGetPlacement = icd.syncGetPlacement();
		syncIsPrimitive = icd.syncIsPrimitive();
		syncIsParameter = icd.syncIsParameter();
		astPath = ModelicaASTRegistry.getInstance().createPath(
				icd.getComponentDecl());
		params = getParameters(icd);
	}

	public List<String[]> getParams() {
		return params;
	}

	public Stack<String> getComponentASTPath() {
		return astPath;
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

	private List<String[]> getParameters(InstComponentDecl icd) {
		List<String[]> parameters = new ArrayList<String[]>();
		collectParameters(icd, parameters);
		return parameters;
	}

	private void collectParameters(InstNode node, List<String[]> parameters) {
		for (InstExtends ie : node.syncGetInstExtendss()) {
			collectParameters(ie, parameters);
		}
		for (InstComponentDecl icd : node.syncGetInstComponentDecls()) {
			if (icd.syncIsPrimitive() && icd.syncIsParameter()) {
				String[] res = new String[2];
				res[0] = icd.syncName();
				InstPrimitive ip = (InstPrimitive) icd;
				res[1] = ip.ceval().toString();
				parameters.add(res);
			}
		}
	}
}
