package org.jmodelica.ide.graphical.proxy;

import java.util.Stack;

import org.jmodelica.icons.coord.Placement;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstComponentDecl;

public class ComponentDiagramProxy extends AbstractDiagramProxy {

	private ComponentProxy component;

	public ComponentDiagramProxy(ComponentProxy component) {
		this.component = component;
	}

	@Override
	protected InstComponentDecl getASTNode() {
		return component.getComponentDecl();
	}

	@Override
	protected InstClassDecl getClassDecl() {
		return getASTNode().myInstClass();
	}

	@Override
	protected InstComponentDecl getComponentDecl() {
		return getASTNode();
	}

	@Override
	public ComponentProxy addComponent(String className, String componentName, Placement placement) {
		throw new UnsupportedOperationException("It is not possible to alter component definition!");
	}

	@Override
	public void removeComponent(ComponentProxy component) {
		throw new UnsupportedOperationException("It is not possible to alter component definition!");
	}

	@Override
	public ConnectionProxy addConnection(ConnectorProxy source, ConnectorProxy target) {
		throw new UnsupportedOperationException("It is not possible to alter component definition!");
	}

	@Override
	protected void addConnection(ConnectionProxy connection) {
		throw new UnsupportedOperationException("It is not possible to alter component definition!");
	}

	@Override
	protected boolean removeConnection(ConnectionProxy connection) {
		throw new UnsupportedOperationException("It is not possible to alter component definition!");
	}
	
	@Override
	protected void setParameterValue(Stack<String> path, String value) {
		component.setParameterValue(path, value);
	}

}
