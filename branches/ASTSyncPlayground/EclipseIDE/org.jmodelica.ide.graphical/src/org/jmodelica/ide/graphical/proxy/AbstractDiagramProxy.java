package org.jmodelica.ide.graphical.proxy;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Stack;
import java.util.Map.Entry;
import java.util.Set;

import org.jmodelica.icons.Layer;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.ide.sync.ASTPathPart;
import org.jmodelica.modelica.compiler.ConnectClause;
import org.jmodelica.modelica.compiler.FAbstractEquation;
import org.jmodelica.modelica.compiler.FConnectClause;
import org.jmodelica.modelica.compiler.InstComponentDecl;
import org.jmodelica.modelica.compiler.InstExtends;
import org.jmodelica.modelica.compiler.InstNode;

public abstract class AbstractDiagramProxy extends AbstractNodeProxy {

	private Map<String, ConnectionProxy> connectionMap = new HashMap<String, ConnectionProxy>();
	private Map<String, ComponentProxy> componentMap = new HashMap<String, ComponentProxy>();

	@Override
	protected abstract Stack<ASTPathPart> getASTPath();

	@Override
	protected String buildDiagramName() {
		return "";
	}

	@Override
	public abstract Layer getLayer();

	@Override
	protected Map<String, ComponentProxy> getComponentMap() {
		return componentMap;
	}

	protected Map<String, ConnectionProxy> getConnectionMap() {
		return connectionMap;
	}

	public void constructConnections(InstNode node) {
		for (InstExtends ie : node.syncGetInstExtendss()) {
			constructConnections(ie);
		}
		for (FAbstractEquation fae : node.syncGetFAbstractEquations()) {
			if (fae instanceof FConnectClause) {
				FConnectClause fcc = (FConnectClause) fae;
				ConnectClause connectClause = fcc.syncGetConnectClause();
				if (connectionMap.containsKey(connectClause.outlineId()))
					continue;
				ConnectorProxy source = getConnectorFromDecl(fcc
						.syncGetConnector1().syncGetInstAccess()
						.syncMyInstComponentDecl());
				if (source == null)
					continue;
				ConnectorProxy target = getConnectorFromDecl(fcc
						.syncGetConnector2().syncGetInstAccess()
						.syncMyInstComponentDecl());
				if (target == null)
					continue;
				ConnectionProxy connection = new ConnectionProxy(source,
						target, connectClause, this);
				connectionMap.put(connectClause.outlineId(), connection);
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

	protected ConnectionProxy getConnection(ConnectorProxy source,
			ConnectorProxy target) {
		for (Entry<String, ConnectionProxy> entry : connectionMap.entrySet()) {
			ConnectionProxy proxy = entry.getValue();
			if (proxy.getSource() == source && proxy.getTarget() == target) {
				return proxy;
			}
		}
		return null;
	}

	/**
	 * protected CachedConnectClause getConnection( CachedConnectClause
	 * connectClause) { return searchForConnection(getCachedASTNode(),
	 * connectClause); }
	 * 
	 * private static CachedConnectClause searchForConnection(CachedInstNode
	 * node, CachedConnectClause connectClause) { for (CachedConnectClause ccc :
	 * node.getConnections()) { if (ccc == connectClause) return ccc; } for
	 * (CachedInstExtends ie : node.syncGetInstExtendss()) { CachedConnectClause
	 * val = searchForConnection(ie, connectClause); if (val != null) return
	 * val; }
	 * System.err.println("Unable to find FConnectClause for ConnectClause: " +
	 * connectClause); return null; }
	 */

	@Override
	public AbstractDiagramProxy getDiagram() {
		return this;
	}

	public void addComponent(String className, Placement placement,
			int actionUndoId) {
		String componentName = generateUniqueName(className);
		addComponent(className, componentName, placement, actionUndoId);
	}

	public abstract void addComponent(String className, String componentName,
			Placement placement, int actionUndoId);

	public abstract void removeComponent(ComponentProxy component,
			int actionUndoId);

	public abstract void addConnection(String sourceDiagramName,
			String targetDiagramName, int actionUndoId);

	protected abstract void addConnection(ConnectionProxy connection,
			int actionUndoId);

	public abstract void removeConnection(ConnectionProxy connection,
			int actionUndoId);

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

	public abstract void moveComponent(ComponentProxy component, double x,
			double y);

	public abstract void rotateComponent(ComponentProxy component, double angle);

	public abstract void resizeComponent(ComponentProxy component, double x,
			double y, double x2, double y2);

	public abstract void addBendPoint(ConnectionProxy connection, double x,
			double y, int index);

	public abstract void removeBendPoint(ConnectionProxy connection, int index);

	public abstract void moveBendPoint(ConnectionProxy connection, double x,
			double y, int index);

	public abstract String syncGetClassIconName();
}