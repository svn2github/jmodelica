package org.jmodelica.ide.graphical.proxy;

import org.jmodelica.icons.coord.Placement;
import org.jmodelica.icons.primitives.Line;
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
	public void addComponent(String className, String componentName, Placement placement) {
		throw new UnsupportedOperationException("It is not possible to alter component definition!");
	}

	@Override
	public void removeComponent(ComponentProxy component) {
		throw new UnsupportedOperationException("It is not possible to alter component definition!");
	}

	@Override
	public void addConnection(String sourceID, String targetID, Line lineCache) {
		throw new UnsupportedOperationException("It is not possible to alter component definition!");
	}

	@Override
	public boolean removeConnection(String sourceID, String targetID) {
		throw new UnsupportedOperationException("It is not possible to alter component definition!");
	}

}
