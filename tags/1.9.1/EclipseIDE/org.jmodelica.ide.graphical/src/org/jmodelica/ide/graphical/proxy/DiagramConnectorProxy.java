package org.jmodelica.ide.graphical.proxy;

public class DiagramConnectorProxy extends ConnectorProxy {

	public DiagramConnectorProxy(String componentName, AbstractNodeProxy parent) {
		super(componentName, parent);
	}
	
	@Override
	protected boolean inDiagram() {
		return true;
	}
}
