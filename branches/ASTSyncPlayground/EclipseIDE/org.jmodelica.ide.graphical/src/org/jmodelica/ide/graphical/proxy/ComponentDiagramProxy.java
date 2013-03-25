package org.jmodelica.ide.graphical.proxy;

import java.util.Stack;

import org.jmodelica.icons.coord.Placement;
import org.jmodelica.ide.graphical.proxy.cache.CachedInstClassDecl;
import org.jmodelica.ide.graphical.proxy.cache.CachedInstComponentDecl;
import org.jmodelica.ide.graphical.proxy.cache.CachedInstNode;

public class ComponentDiagramProxy extends AbstractDiagramProxy {

	private ComponentProxy component;

	public ComponentDiagramProxy(ComponentProxy component) {
		this.component = component;
	}
	@Override
	public String getQualifiedClassName() {
		return component.getQualifiedClassName();
	}

	@Override
	protected CachedInstNode getCachedASTNode() {
		return component.getComponentDecl();
	}

	@Override
	protected CachedInstClassDecl getClassDecl() {
		return null;
	}

	@Override
	protected CachedInstComponentDecl getComponentDecl() {
		return component.getComponentDecl();
	}

	@Override
	public void addComponent(String className, String componentName, Placement placement) {
		throw new UnsupportedOperationException("It is not possible to alter component definition!");
	}

	@Override
	public void removeComponent(ComponentProxy component) {
		throw new UnsupportedOperationException("It is not possible to alter component definition!");
	}

	@Override
	public void addConnection(String sourceDiagramName, String targetDiagramName) {
		throw new UnsupportedOperationException("It is not possible to alter component definition!");
	}

	@Override
	protected void addConnection(ConnectionProxy connection) {
		throw new UnsupportedOperationException("It is not possible to alter component definition!");
	}

	@Override
	public void removeConnection(ConnectionProxy connection) {
		throw new UnsupportedOperationException("It is not possible to alter component definition!");
	}
	
	@Override
	protected void setParameterValue(Stack<String> path, String value) {
		component.setParameterValue(path, value);
	}

}
