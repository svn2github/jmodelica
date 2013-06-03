package org.jmodelica.ide.graphical.proxy;

import java.util.List;
import java.util.Map;
import java.util.Stack;

import org.jastadd.ed.core.model.IASTPathPart;
import org.jmodelica.icons.Layer;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.primitives.GraphicItem;
import org.jmodelica.modelica.compiler.InstComponentDecl;
import org.jmodelica.modelica.compiler.InstExtends;
import org.jmodelica.modelica.compiler.InstNode;

public abstract class AbstractNodeProxy extends Observable {

	protected abstract Stack<IASTPathPart> getASTPath();

	abstract protected Map<String, ComponentProxy> getComponentMap();

	abstract protected void setParameterValue(
			Stack<IASTPathPart> componentASTPath, Stack<String> path,
			String value);

	protected abstract String buildDiagramName();

	public abstract AbstractDiagramProxy getDiagram();

	public abstract Layer getLayer();

	public String getClassName() {
		return getDiagram().syncGetClassIconName();
	}

	public String getComponentName() {
		return null;
	}

	public String getQualifiedComponentName() {
		return null;
	}

	protected abstract boolean inDiagram();

	public abstract List<GraphicItem> getGraphics();

	protected static void collectGraphics(InstNode node,
			List<GraphicItem> graphics, boolean inDiagram) {
		for (InstExtends ie : node.syncGetInstExtendss()) {
			collectGraphics(ie, graphics, inDiagram);
		}
		if (inDiagram)
			graphics.addAll(node.cacheDiagramLayer().getGraphics());
		else
			graphics.addAll(node.cacheIconLayer().getGraphics());
	}

	public abstract List<ComponentProxy> getComponents();

	protected void collectComponents(InstNode node,
			List<ComponentProxy> components) {
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
			String mapName = buildMapName(icd.syncQualifiedName(), isConnector,
					inDiagram && isConnector);
			ComponentProxy component = getComponentMap().get(mapName);
			if (component == null) {
				if (isConnector && inDiagram)
					component = new DiagramConnectorProxy(icd, icd.syncName(),
							this);
				else if (isConnector && !inDiagram)
					component = new IconConnectorProxy(icd, icd.syncName(),
							this);
				else
					component = new ComponentProxy(icd, icd.syncName(), this);
				getComponentMap().put(mapName, component);
			}
			components.add(component);
		}
	}

	public String getParameterValue(String parameter) {
		return "";
	}

	protected static String buildMapName(String qualifiedName,
			boolean isConnector, boolean inDiagram) {
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