package org.jmodelica.ide.graphical.proxy;

import org.jmodelica.modelica.compiler.InstComponentDecl;

public class DiagramConnectorProxy extends ConnectorProxy {

	public DiagramConnectorProxy(InstComponentDecl icdc, String componentName,
			AbstractNodeProxy parent) {
		super(icdc, componentName, parent);
	}

	@Override
	protected boolean inDiagram() {
		return true;
	}
}