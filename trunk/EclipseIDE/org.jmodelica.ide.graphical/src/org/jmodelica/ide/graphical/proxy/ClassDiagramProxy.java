package org.jmodelica.ide.graphical.proxy;

import org.jmodelica.icons.coord.Placement;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.modelica.compiler.FConnectClause;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstComponentDecl;

public class ClassDiagramProxy extends AbstractDiagramProxy {

	public static final Object COMPONENT_ADDED = new Object();
	public static final Object COMPONENT_REMOVED = new Object();
	
	private InstClassDecl instClassDecl;

	public ClassDiagramProxy(InstClassDecl instClassDecl) {
		this.instClassDecl = instClassDecl;
	}

	@Override
	protected InstClassDecl getASTNode() {
		return instClassDecl;
	}

	@Override
	protected InstComponentDecl getComponentDecl() {
		return null;
	}

	@Override
	protected InstClassDecl getClassDecl() {
		return getASTNode();
	}

	@Override
	public void addComponent(String className, String componentName, Placement placement) {
		getASTNode().addComponent(className, componentName, placement);
		notifyObservers(COMPONENT_ADDED);
	}

	@Override
	public void removeComponent(ComponentProxy component) {
		getASTNode().removeComponent(component.getComponentDecl());
		notifyObservers(COMPONENT_REMOVED);
	}

	@Override
	public void addConnection(String sourceID, String targetID, Line lineCache) {
		FConnectClause fcc = getASTNode().addConnection(sourceID, targetID, lineCache);
		((ConnectorProxy) getComponentMap().get(fcc.getConnector1().getInstAccess().myInstComponentDecl().qualifiedName())).sourceConnectionsHasChanged();
		((ConnectorProxy) getComponentMap().get(fcc.getConnector2().getInstAccess().myInstComponentDecl().qualifiedName())).targetConnectionsHasChanged();
	}

	@Override
	public boolean removeConnection(String sourceID, String targetID) {
		FConnectClause fcc = getConnection(sourceID, targetID);
		if (!getASTNode().removeFAbstractEquation(fcc))
			return false;
		((FullClassDecl) getASTNode().getClassDecl()).removeEquation(fcc.getConnectClause());
		((ConnectorProxy) getComponentMap().get(fcc.getConnector1().getInstAccess().myInstComponentDecl().qualifiedName())).sourceConnectionsHasChanged();
		((ConnectorProxy) getComponentMap().get(fcc.getConnector2().getInstAccess().myInstComponentDecl().qualifiedName())).targetConnectionsHasChanged();
		return true;
	}

}
