package org.jmodelica.ide.graphical.proxy;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.jmodelica.icons.Layer;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.ide.graphical.proxy.cache.CachedConnectClause;
import org.jmodelica.ide.graphical.proxy.cache.CachedInstExtends;
import org.jmodelica.ide.graphical.proxy.cache.CachedInstNode;

public abstract class AbstractDiagramProxy extends AbstractNodeProxy {

	private Map<CachedConnectClause, ConnectionProxy> connectionMap = new HashMap<CachedConnectClause, ConnectionProxy>();
	private Map<String, ComponentProxy> componentMap = new HashMap<String, ComponentProxy>();

	@Override
	protected abstract CachedInstNode getCachedASTNode();

	@Override
	protected String buildDiagramName() {
		return "";
	}

	@Override
	public Layer getLayer() {
		return getCachedASTNode().syncGetDiagramLayer();
	}

	@Override
	protected Map<String, ComponentProxy> getComponentMap() {
		return componentMap;
	}

	protected Map<CachedConnectClause, ConnectionProxy> getConnectionMap() {
		return connectionMap;
	}

	public void constructConnections() {
		Iterator<Entry<CachedConnectClause, ConnectionProxy>> it = connectionMap
				.entrySet().iterator();
		while (it.hasNext()) {
			it.next().getValue().dispose();
			it.remove();
		}
		constructConnections(getCachedASTNode());
	}

	public void constructConnections(CachedInstNode node) {
		for (CachedInstExtends ie : node.syncGetInstExtendss()) {
			constructConnections(ie);
		}
		for (CachedConnectClause ccc : node.getConnections()) {
			if (connectionMap.containsKey(ccc))
				continue;
			ConnectorProxy source = getConnectorFromDecl(ccc
					.getConnInstComp1QName());
			if (source == null)
				continue;
			ConnectorProxy target = getConnectorFromDecl(ccc
					.getConnInstComp2QName());
			if (target == null)
				continue;
			ConnectionProxy connection = new ConnectionProxy(source, target,
					ccc, this);
			connectionMap.put(ccc, connection);
		}
	}

	private ConnectorProxy getConnectorFromDecl(String instCompQualifiedName) {
		String mapName = buildMapName(instCompQualifiedName, true, false);
		ComponentProxy connector = getComponentMap().get(mapName);
		if (connector != null)
			return (ConnectorProxy) connector;
		mapName = buildMapName(instCompQualifiedName, true, true);
		connector = getComponentMap().get(mapName);
		if (connector != null)
			return (ConnectorProxy) connector;
		return null;
	}

	@Override
	protected boolean inDiagram() {
		return true;
	}

	protected ConnectionProxy getConnection(ConnectorProxy source,
			ConnectorProxy target) {
		for (Entry<CachedConnectClause, ConnectionProxy> entry : connectionMap
				.entrySet()) {
			ConnectionProxy proxy = entry.getValue();
			if (proxy.getSource() == source && proxy.getTarget() == target) {
				return proxy;
			}
		}
		return null;
	}

	protected CachedConnectClause getConnection(
			CachedConnectClause connectClause) {
		return searchForConnection(getCachedASTNode(), connectClause);
	}

	private static CachedConnectClause searchForConnection(CachedInstNode node,
			CachedConnectClause connectClause) {
		for (CachedConnectClause ccc : node.getConnections()) {
			if (ccc == connectClause)
				return ccc;
		}
		for (CachedInstExtends ie : node.syncGetInstExtendss()) {
			CachedConnectClause val = searchForConnection(ie, connectClause);
			if (val != null)
				return val;
		}
		System.err.println("Unable to find FConnectClause for ConnectClause: "
				+ connectClause);
		return null;
	}

	@Override
	public AbstractDiagramProxy getDiagram() {
		return this;
	}

	public void addComponent(String className, Placement placement) {
		String componentName = generateUniqueName(className);
		addComponent(className, componentName, placement);
	}

	public abstract void addComponent(String className, String componentName,
			Placement placement);

	public abstract void removeComponent(ComponentProxy component);

	public abstract void addConnection(String sourceDiagramName,
			String targetDiagramName);

	protected abstract void addConnection(ConnectionProxy connection);

	public abstract void removeConnection(ConnectionProxy connection);

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

	public void undoRemoveComponent() {}

	public void undoAddComponent() {}
}
