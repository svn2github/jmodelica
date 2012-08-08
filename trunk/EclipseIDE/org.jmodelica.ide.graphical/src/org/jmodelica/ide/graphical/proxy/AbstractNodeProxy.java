package org.jmodelica.ide.graphical.proxy;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.jmodelica.icons.Observable;
import org.jmodelica.icons.primitives.GraphicItem;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstComponentDecl;
import org.jmodelica.modelica.compiler.InstExtends;
import org.jmodelica.modelica.compiler.InstNode;
import org.jmodelica.modelica.compiler.InstPrimitive;

public abstract class AbstractNodeProxy extends Observable {

	protected abstract InstComponentDecl getInstComponentDecl(String componentName);

	protected abstract InstClassDecl getClassDecl();

	protected abstract InstComponentDecl getComponentDecl();
	
	protected abstract InstNode getASTNode();

	abstract protected Map<String, ComponentProxy> getComponentMap();

	protected abstract  String buildDiagramName();
	
	public abstract AbstractDiagramProxy getDiagram();

	public String getClassName() {
		return getClassDecl().getClassIconName();
	}
	
	public String getQualifiedClassName() {
		return getClassDecl().qualifiedName();
	}
	
	public String getComponentName() {
		InstComponentDecl componentDecl = getComponentDecl();
		if (componentDecl != null)
			return componentDecl.name();
		else
			return null;
	}

	public String getQualifiedComponentName() {
		InstComponentDecl componentDecl = getComponentDecl();
		if (componentDecl != null)
			return componentDecl.qualifiedName();
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
		for (InstExtends ie : node.getInstExtendss()) {
			collectGraphics(ie, graphics, inDiagram);
		}
		if (inDiagram)
			graphics.addAll(node.iconAnnotation().forPath("Diagram/graphics").createGraphics());
		else
			graphics.addAll(node.iconAnnotation().forPath("Icon/graphics").createGraphics());
	}

	public String getParameterValue(String parameter) {
		InstNode in = getComponentDecl();
		if (in == null)
			in = getClassDecl();
		if (in == null)
			return null;
		for (Object o : in.memberInstComponent(parameter)) {
			if (o instanceof InstPrimitive) {
				InstPrimitive ip = (InstPrimitive) o;
				return ip.ceval().toString();
			}
		}
		return null;
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
