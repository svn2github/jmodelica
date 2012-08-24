package org.jmodelica.ide.graphical.proxy;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.jmodelica.icons.Layer;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.modelica.compiler.ConnectClause;
import org.jmodelica.modelica.compiler.FAbstractEquation;
import org.jmodelica.modelica.compiler.FConnectClause;
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

	@Override
	public Layer getLayer() {
		return getASTNode().syncGetDiagramLayer();
	}

	@Override
	protected Map<String, ComponentProxy> getComponentMap() {
		return componentMap;
	}
	
	protected Map<ConnectClause, ConnectionProxy> getConnectionMap() {
		return connectionMap;
	}

	public void constructConnections() {
		Iterator<Entry<ConnectClause, ConnectionProxy>> it = connectionMap.entrySet().iterator();
		while (it.hasNext()) {
			it.next().getValue().dispose();
			it.remove();
		}
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
				if (source == null)
					continue;
				ConnectorProxy target = getConnectorFromDecl(fcc.syncGetConnector2().syncGetInstAccess().syncMyInstComponentDecl());
				if (target == null)
					continue;
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
		return null;
	}

	@Override
	protected boolean inDiagram() {
		return true;
	}
	
	protected ConnectionProxy getConnection(ConnectorProxy source, ConnectorProxy target) {
		for (Entry<ConnectClause, ConnectionProxy> entry : connectionMap.entrySet()) {
			ConnectionProxy proxy = entry.getValue();
			if (proxy.getSource() == source && proxy.getTarget() == target) {
				return proxy;
			}
		}
		return null;
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
