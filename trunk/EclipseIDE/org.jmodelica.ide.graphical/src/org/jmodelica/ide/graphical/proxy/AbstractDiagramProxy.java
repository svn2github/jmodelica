package org.jmodelica.ide.graphical.proxy;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.jmodelica.icons.coord.Placement;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.modelica.compiler.FAbstractEquation;
import org.jmodelica.modelica.compiler.FConnectClause;
import org.jmodelica.modelica.compiler.FIdUseInstAccess;
import org.jmodelica.modelica.compiler.InstBaseClassDecl;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstComponentDecl;
import org.jmodelica.modelica.compiler.InstExtends;
import org.jmodelica.modelica.compiler.InstNode;

public abstract class AbstractDiagramProxy extends AbstractNodeProxy {

	private Map<FConnectClause, ConnectionProxy> connectionMap = new HashMap<FConnectClause, ConnectionProxy>();
	private Map<String, ComponentProxy> componentMap = new HashMap<String, ComponentProxy>();

	@Override
	protected abstract InstNode getASTNode();

	public List<ComponentProxy> getComponents() {
		List<ComponentProxy> components = new ArrayList<ComponentProxy>();
		collectComponents(getASTNode(), components);
		return components;
	}

	@Override
	protected Map<String, ComponentProxy> getComponentMap() {
		return componentMap;
	}

	private void collectComponents(InstNode node, List<ComponentProxy> components) {
		for (InstExtends ie : node.getInstExtendss()) {
			collectComponents(ie, components);
		}
		for (InstComponentDecl icd : node.getInstComponentDecls()) {
			InstClassDecl classDecl = icd.myInstClass();
			if (classDecl.isKnown() && classDecl instanceof InstBaseClassDecl) {
				ComponentProxy component = getComponentMap().get(icd.qualifiedName());
				if (component == null) {
					if (icd.isConnector())
						component = new DiagramConnectorProxy(icd.name(), this);
					else
						component = new ComponentProxy(icd.name(), this);
					getComponentMap().put(icd.qualifiedName(), component);
				}
				components.add(component);
			}
		}
	}

	@Override
	protected boolean inDiagram() {
		return true;
	}

	public List<ConnectionProxy> getSourceConnectionsFor(InstComponentDecl connector) {
		List<ConnectionProxy> connections = new ArrayList<ConnectionProxy>();
		collectConnectionsFor(connections, connector, getASTNode(), true);
		return connections;
	}

	public List<ConnectionProxy> getTargetConnectionsFor(InstComponentDecl connector) {
		List<ConnectionProxy> connections = new ArrayList<ConnectionProxy>();
		collectConnectionsFor(connections, connector, getASTNode(), false);
		return connections;
	}

	private void collectConnectionsFor(List<ConnectionProxy> connections, InstComponentDecl connector, InstNode node, boolean isConnector1) {
		for (FAbstractEquation fae : node.getFAbstractEquations()) {
			if (fae instanceof FConnectClause) {
				FConnectClause fcc = (FConnectClause) fae;
				FIdUseInstAccess fiuia;
				if (isConnector1)
					fiuia = fcc.getConnector1();
				else
					fiuia = fcc.getConnector2();
				if (fiuia.getInstAccess().myInstComponentDecl() == connector) {
					ConnectionProxy connection = connectionMap.get(fcc);
					if (connection == null) {
						connection = new ConnectionProxy(fcc.getConnector1().name(), fcc.getConnector2().name(), this);
						connectionMap.put(fcc, connection);
					}
					connections.add(connection);
				}
			}
		}
		for (InstExtends ie : node.getInstExtendss()) {
			collectConnectionsFor(connections, connector, ie, isConnector1);
		}
	}

	protected FConnectClause getConnection(String sourceID, String targetID) {
		return searchForConnection(getASTNode(), sourceID, targetID);
	}

	private static FConnectClause searchForConnection(InstNode node, String sourceID, String targetID) {
		for (FAbstractEquation fae : node.getFAbstractEquations()) {
			if (fae instanceof FConnectClause) {
				FConnectClause fcc = (FConnectClause) fae;
				if (fcc.getConnector1().name().equals(sourceID) && fcc.getConnector2().name().equals(targetID))
					return fcc;
			}
		}
		for (InstExtends ie : node.getInstExtendss()) {
			FConnectClause val = searchForConnection(ie, sourceID, targetID);
			if (val != null)
				return val;
		}
		return null;
	}

	@Override
	protected InstComponentDecl getInstComponentDecl(String componentName) {
		return getASTNode().simpleLookupInstComponentDecl(componentName);
	}

	@Override
	public AbstractDiagramProxy getDiagram() {
		return this;
	}

	public ComponentProxy addComponent(String className, Placement placement) {
		String componentName = generateUniqueName(className);
		addComponent(className, componentName, placement);
		return new ComponentProxy(componentName, this);
	}

	public abstract void addComponent(String className, String componentName, Placement placement);

	public abstract void removeComponent(ComponentProxy component);

	public abstract void addConnection(String sourceID, String targetID, Line lineCache);

	public abstract boolean removeConnection(String sourceID, String targetID);

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
