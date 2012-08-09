package org.jmodelica.ide.graphical.proxy;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.jmodelica.icons.Layer;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.primitives.GraphicItem;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstComponentDecl;
import org.jmodelica.modelica.compiler.InstExtends;
import org.jmodelica.modelica.compiler.InstNode;

public abstract class AbstractNodeProxy extends Observable {

	protected abstract InstComponentDecl getInstComponentDecl(String componentName);

	protected abstract InstClassDecl getClassDecl();

	protected abstract InstComponentDecl getComponentDecl();
	
	protected abstract InstNode getASTNode();

	abstract protected Map<String, ComponentProxy> getComponentMap();

	protected abstract  String buildDiagramName();
	
	public abstract AbstractDiagramProxy getDiagram();
	
	public abstract Layer getLayer();

	public String getClassName() {
		return getClassDecl().syncGetClassIconName();
	}
	
	public String getQualifiedClassName() {
		return getClassDecl().syncQualifiedName();
	}
	
	public String getComponentName() {
		InstComponentDecl componentDecl = getComponentDecl();
		if (componentDecl != null)
			return componentDecl.syncName();
		else
			return null;
	}

	public String getQualifiedComponentName() {
		InstComponentDecl componentDecl = getComponentDecl();
		if (componentDecl != null)
			return componentDecl.syncQualifiedName();
		else
			return null;
	}
	
	protected abstract boolean inDiagram();
	
	public List<GraphicItem> getGraphics() {
		List<GraphicItem> graphics = new ArrayList<GraphicItem>();
		collectGraphics(getASTNode(), graphics, inDiagram());
		return graphics;
	}
	
	protected static void collectGraphics(InstNode node, List<GraphicItem> graphics, boolean inDiagram) {
		for (InstExtends ie : node.syncGetInstExtendss()) {
			collectGraphics(ie, graphics, inDiagram);
		}
		if (inDiagram)
			graphics.addAll(node.syncGetDiagramLayer().getGraphics());
		else
			graphics.addAll(node.syncGetIconLayer().getGraphics());
	}
	
	public List<ComponentProxy> getComponents() {
		List<ComponentProxy> components = new ArrayList<ComponentProxy>();
		collectComponents(getASTNode(), components);
		return components;
	}
	
	private void collectComponents(InstNode node, List<ComponentProxy> components) {
		for (InstExtends ie : node.syncGetInstExtendss()) {
			collectComponents(ie, components);
		}
		for (InstComponentDecl icd : node.syncGetInstComponentDecls()) {
			boolean isConnector = icd.syncIsConnector();
			boolean inDiagram = inDiagram();
			if (!inDiagram && !isConnector)
				continue;
			if (!icd.syncIsIconRenderable())
				continue;
			String mapName = buildMapName(icd.syncQualifiedName(), isConnector, inDiagram && isConnector);
			ComponentProxy component = getComponentMap().get(mapName);
			if (component == null) {
				if (isConnector && inDiagram)
					component = new DiagramConnectorProxy(icd.syncName(), this);
				else if (isConnector && !inDiagram)
					component = new IconConnectorProxy(icd.syncName(), this);
				else
					component = new ComponentProxy(icd.syncName(), this);
				getComponentMap().put(mapName, component);
			}
			components.add(component);
		}
	}

	public String getParameterValue(String parameter) {
		return getASTNode().syncLookupParameterValue(parameter);
	}
	
	protected static String buildMapName(String qualifiedName, boolean isConnector, boolean inDiagram) {
		String name = qualifiedName;
		if (!isConnector)
			return name;
		name += ":connector";
		if (inDiagram)
			name += ":diagram";
		else
			name += ":icon";
		return name;
	}
}
