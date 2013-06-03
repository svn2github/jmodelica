package org.jmodelica.ide.graphical.proxy;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Stack;

import org.jastadd.ed.core.model.IASTPathPart;
import org.jmodelica.icons.Layer;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;
import org.jmodelica.icons.coord.Extent;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.icons.coord.Transformation;
import org.jmodelica.icons.primitives.GraphicItem;
import org.jmodelica.ide.graphical.util.Transform;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.modelica.compiler.InstComponentDecl;
import org.jmodelica.modelica.compiler.InstExtends;
import org.jmodelica.modelica.compiler.InstNode;
import org.jmodelica.modelica.compiler.InstPrimitive;

public class ComponentProxy extends AbstractNodeProxy implements Observer {

	public static final Object PLACEMENT_CHANGED = new Object();
	protected static final Object COLLECT_CONNECTIONS = new Object();

	private String componentName;
	private AbstractNodeProxy parent;
	private Stack<IASTPathPart> astPath;
	private Placement cachedPlacement;
	private Layer cachedIconLayer;
	List<ParameterProxy> parameters = new ArrayList<ParameterProxy>();
	private Layer cachedDiagramLayer;
	private String syncQualifiedName;
	private List<GraphicItem> graphics = new ArrayList<GraphicItem>();
	private List<ComponentProxy> components = new ArrayList<ComponentProxy>();

	public ComponentProxy(InstComponentDecl icdc, String componentName,
			AbstractNodeProxy parent) {
		this.componentName = componentName;
		this.parent = parent;
		this.astPath = ModelicaASTRegistry.getInstance().createDefPath(
				icdc.getComponentDecl());
		parent.addObserver(this);
		cachedPlacement = icdc.cachePlacement();
		cachedIconLayer = icdc.cacheIconLayer();
		cachedDiagramLayer = icdc.cacheDiagramLayer();
		collectParameters(icdc, parameters);
		syncQualifiedName = icdc.syncQualifiedName();
		collectComponents(icdc, components);
		collectGraphics(icdc, graphics, inDiagram());
	}

	private void collectParameters(InstNode node,
			List<ParameterProxy> parameters) {
		for (InstExtends ie : node.syncGetInstExtendss()) {
			collectParameters(ie, parameters);
		}
		for (InstComponentDecl icd : node.syncGetInstComponentDecls()) {
			if (icd.syncIsPrimitive() && icd.syncIsParameter()) {
				ParameterProxy res = new ParameterProxy(icd.syncName(), this,
						((InstPrimitive) icd).ceval().toString());
				parameters.add(res);
			}
		}
	}

	protected AbstractNodeProxy getParent() {
		return parent;
	}

	@Override
	public String getComponentName() {
		return syncQualifiedName;
	}

	@Override
	public String getQualifiedComponentName() {
		return syncQualifiedName;
	}

	@Override
	public String buildDiagramName() {
		String parentName = parent.buildDiagramName();
		if (parentName.length() == 0)
			return componentName;
		else
			return parentName + "." + componentName;
	}

	@Override
	public Stack<IASTPathPart> getASTPath() {
		return astPath;
	}

	@Override
	protected boolean inDiagram() {
		return false;
	}

	public Transform calculateTransform(Transform parent) { // TODO:refactor
		// Based on
		// org.jmodelica.icons.drawing.AWTIconDrawer.setTransformation()
		Transformation compTransformation = getPlacement().getTransformation();
		Extent transformationExtent = compTransformation.getExtent();
		Extent componentExtent = getLayer().getCoordinateSystem().getExtent();
		Transform t = parent.clone();
		t.translate(Transform.yInverter.transform(compTransformation
				.getOrigin()));
		t.translate(Transform.yInverter.transform(transformationExtent
				.getMiddle()));

		if (transformationExtent.getP2().getX() < transformationExtent.getP1()
				.getX()) {
			t.scale(-1.0, 1.0);
		}
		if (transformationExtent.getP2().getY() < transformationExtent.getP1()
				.getY()) {
			t.scale(1.0, -1.0);
		}

		double angle = -compTransformation.getRotation() * Math.PI / 180;
		t.rotate(angle);

		t.scale(transformationExtent.getWidth() / componentExtent.getWidth(),
				transformationExtent.getHeight() / componentExtent.getHeight());

		return t;
	}

	@Override
	public AbstractDiagramProxy getDiagram() {
		return parent.getDiagram();
	}

	@Override
	protected Map<String, ComponentProxy> getComponentMap() {
		return parent.getComponentMap();
	}

	public Placement getPlacement() {
		return cachedPlacement;
	}

	@Override
	public Layer getLayer() {
		return cachedIconLayer;
	}

	public String getMapName() {
		return buildMapName(getQualifiedComponentName(), isConnector(),
				isConnector());
	}

	public boolean isConnector() {
		return false;
	}

	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == parent && flag == COLLECT_CONNECTIONS)
			notifyObservers(COLLECT_CONNECTIONS, additionalInfo);
	}

	public List<ConnectionProxy> getConnections() {
		List<ConnectionProxy> removedConnections = new ArrayList<ConnectionProxy>();
		notifyObservers(COLLECT_CONNECTIONS, removedConnections);
		return removedConnections;
	}

	public boolean isParent(AbstractNodeProxy node) {
		if (parent == node)
			return true;
		else
			return false;
	}

	@Override
	public String toString() {
		return buildDiagramName();
	}

	@Override
	public String getParameterValue(String parameter) {
		for (ParameterProxy pp : getParameters())
			if (pp.getDisplayName().equals(parameter))
				return pp.getValue();
		return "";
	}

	public List<ParameterProxy> getParameters() {
		return parameters;
	}

	@Override
	protected void setParameterValue(Stack<IASTPathPart> componentASTPath,
			Stack<String> path, String value) {
		path.push(componentName);
		getParent().setParameterValue(astPath, path, value);
	}

	public void setComponentName(String newName) {
		componentName = newName;
	}

	public Layer getDiagramLayer() {
		return cachedDiagramLayer;
	}

	@Override
	public List<ComponentProxy> getComponents() {
		return components;
	}

	@Override
	public List<GraphicItem> getGraphics() {
		return graphics;
	}
}