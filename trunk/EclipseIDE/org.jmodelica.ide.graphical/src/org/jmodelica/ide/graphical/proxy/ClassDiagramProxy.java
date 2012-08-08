package org.jmodelica.ide.graphical.proxy;

import java.io.ByteArrayInputStream;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.modelica.compiler.ConnectClause;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstComponentDecl;
import org.jmodelica.modelica.compiler.StoredDefinition;

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
	public ComponentProxy addComponent(String className, String componentName, Placement placement) {
		InstComponentDecl icd = getASTNode().addComponent(className, componentName, placement);
		String mapName = buildMapName(icd.qualifiedName(), icd.isConnector(), icd.isConnector());
		ComponentProxy component = getComponentMap().get(mapName);
		if (component == null) {
			if (icd.isConnector()) {
				component = new DiagramConnectorProxy(componentName, this);
			} else {
				component = new ComponentProxy(componentName, this);
			}
			getComponentMap().put(mapName, component);
		}
		notifyObservers(COMPONENT_ADDED);
		return component;
	}

	@Override
	public void removeComponent(ComponentProxy component) {
		getASTNode().removeComponent(component.getComponentDecl());
		notifyObservers(COMPONENT_REMOVED);
	}
	
	@Override
	public ConnectionProxy addConnection(ConnectorProxy source, ConnectorProxy target) {
		ConnectClause connectClause = getASTNode().addConnection(source.buildDiagramName(), target.buildDiagramName());
		ConnectionProxy connection = new ConnectionProxy(source, target, connectClause, this);
		getConnectionMap().put(connectClause, connection);
		return connection;
	}
	
	@Override
	protected void addConnection(ConnectionProxy connection) {
		getASTNode().addConnection(connection.getConnectClause());
	}

	@Override
	protected boolean removeConnection(ConnectionProxy connection) {
		getASTNode().removeConnection(getConnection(connection.getConnectClause()));
		return true;
	}

	public void saveModelicaFile(IProgressMonitor monitor) throws CoreException {
		StoredDefinition definition = instClassDecl.getDefinition();
		definition.getFile().setContents(new ByteArrayInputStream(definition.prettyPrintFormatted().getBytes()), false, true, monitor);
	}

}
