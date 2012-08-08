package org.jmodelica.ide.graphical.proxy;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.eclipse.core.runtime.Assert;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.modelica.compiler.ConnectClause;
import org.jmodelica.modelica.compiler.FAbstractEquation;
import org.jmodelica.modelica.compiler.FConnectClause;
import org.jmodelica.modelica.compiler.InstBaseClassDecl;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstComponentDecl;
import org.jmodelica.modelica.compiler.InstExtends;
import org.jmodelica.modelica.compiler.InstNode;

public abstract class AbstractDiagramProxy extends AbstractNodeProxy {

	private Map<ConnectClause, ConnectionProxy> connectionMap = new HashMap<ConnectClause, ConnectionProxy>();
	private Map<String, ComponentProxy> componentMap = new HashMap<String, ComponentProxy>();

	@Override
	protected abstract InstNode getASTNode();
	
	@Override
	protected String buildDiagramName() {
		return "";
	}

	public List<ComponentProxy> getComponents() {
		List<ComponentProxy> components = new ArrayList<ComponentProxy>();
		collectComponents(getASTNode(), components);
		return components;
	}

	@Override
	protected Map<String, ComponentProxy> getComponentMap() {
		return componentMap;
	}
	
	protected Map<ConnectClause, ConnectionProxy> getConnectionMap() {
		return connectionMap;
	}

	private void collectComponents(InstNode node, List<ComponentProxy> components) {
		for (InstExtends ie : node.syncGetInstExtendss()) {
			collectComponents(ie, components);
		}
		for (InstComponentDecl icd : node.syncGetInstComponentDecls()) {
			InstClassDecl classDecl = icd.syncMyInstClass();
			if (!classDecl.syncIsUnknown() && classDecl instanceof InstBaseClassDecl) {
				String mapName = buildMapName(icd.syncQualifiedName(), icd.syncIsConnector(), icd.syncIsConnector());
				ComponentProxy component = getComponentMap().get(mapName);
				if (component == null) {
					if (icd.syncIsConnector())
						component = new DiagramConnectorProxy(icd.syncName(), this);
					else
						component = new ComponentProxy(icd.syncName(), this);
					getComponentMap().put(mapName, component);
				}
				components.add(component);
			}
		}
	}
	
	
	public void constructConnections() {
		constructConnections(getASTNode());
	}
	
	private void constructConnections(InstNode node) {
		for (InstExtends ie : node.syncGetInstExtendss()) {
			constructConnections(ie);
		}
		for (FAbstractEquation fae : node.syncGetFAbstractEquations()) {
			if (fae instanceof FConnectClause) {
				FConnectClause fcc = (FConnectClause) fae;
				ConnectClause connectClause = fcc.syncGetConnectClause();
				if (connectionMap.containsKey(connectClause))
					continue;
				ConnectorProxy source = getConnectorFromDecl(fcc.syncGetConnector1().syncGetInstAccess().syncMyInstComponentDecl());
				Assert.isNotNull(source);
				ConnectorProxy target = getConnectorFromDecl(fcc.syncGetConnector2().syncGetInstAccess().syncMyInstComponentDecl());
				Assert.isNotNull(target);
				ConnectionProxy connection = new ConnectionProxy(source, target, connectClause, this);
				connectionMap.put(connectClause, connection);
			}
		}
	}
	
	private ConnectorProxy getConnectorFromDecl(InstComponentDecl icd) {
		String mapName = buildMapName(icd.syncQualifiedName(), true, false);
		ComponentProxy connector = getComponentMap().get(mapName);
		if (connector != null)
			return (ConnectorProxy) connector;
		mapName = buildMapName(icd.syncQualifiedName(), true, true);
		connector = getComponentMap().get(mapName);
		if (connector != null)
			return (ConnectorProxy) connector;
		throw new IllegalArgumentException();
	}

	@Override
	protected boolean inDiagram() {
		return true;
	}

	protected FConnectClause getConnection(ConnectClause connectClause) {
		return searchForConnection(getASTNode(), connectClause);
	}

	private static FConnectClause searchForConnection(InstNode node, ConnectClause connectClause) {
		for (FAbstractEquation fae : node.syncGetFAbstractEquations()) {
			if (fae instanceof FConnectClause) {
				FConnectClause fcc = (FConnectClause) fae;
				if (fcc.syncGetConnectClause() == connectClause)
					return fcc;
			}
		}
		for (InstExtends ie : node.syncGetInstExtendss()) {
			FConnectClause val = searchForConnection(ie, connectClause);
			if (val != null)
				return val;
		}
		System.err.println("Unable to find FConnectClause for ConnectClause: " + connectClause);
		return null;
	}

	@Override
	protected InstComponentDecl getInstComponentDecl(String componentName) {
		return getASTNode().syncSimpleLookupInstComponentDecl(componentName);
	}

	@Override
	public AbstractDiagramProxy getDiagram() {
		return this;
	}

	public ComponentProxy addComponent(String className, Placement placement) {
		String componentName = generateUniqueName(className);
		return addComponent(className, componentName, placement);
	}

	public abstract ComponentProxy addComponent(String className, String componentName, Placement placement);

	public abstract void removeComponent(ComponentProxy component);

	public abstract ConnectionProxy addConnection(ConnectorProxy source, ConnectorProxy target);
	
	protected abstract void addConnection(ConnectionProxy connection);

	protected abstract boolean removeConnection(ConnectionProxy connection);

	private String generateUniqueName(String className) {
		String baseAutoName = className;
		int index = baseAutoName.lastIndexOf('.');
		if (index != -1)
			baseAutoName = baseAutoName.substring(index + 1);
		Set<String> usedNames = new HashSet<String>();

		for (ComponentProxy c : getComponents()) {
			usedNames.add(c.getComponentName());
		}

		int i = 1;
		String autoName = baseAutoName;
		while (usedNames.contains(autoName)) {
			i++;
			autoName = baseAutoName + i;
		}
		return autoName;
	}

}
