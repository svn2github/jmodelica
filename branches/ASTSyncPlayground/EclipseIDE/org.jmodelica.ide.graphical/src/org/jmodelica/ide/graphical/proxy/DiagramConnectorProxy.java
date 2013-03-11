package org.jmodelica.ide.graphical.proxy;

import org.jmodelica.ide.graphical.proxy.cache.CachedInstComponentDecl;

public class DiagramConnectorProxy extends ConnectorProxy {

	public DiagramConnectorProxy(CachedInstComponentDecl icdc,
			String componentName, AbstractNodeProxy parent) {
		super(icdc, componentName, parent);
	}

	@Override
	protected boolean inDiagram() {
		return true;
	}
}
