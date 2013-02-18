package org.jmodelica.ide.graphical.proxy;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Stack;

import org.jmodelica.icons.Layer;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;
import org.jmodelica.icons.coord.Extent;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.icons.coord.Transformation;
import org.jmodelica.ide.graphical.util.Transform;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstComponentDecl;
import org.jmodelica.modelica.compiler.InstExtends;
import org.jmodelica.modelica.compiler.InstNode;

public class ComponentProxy extends AbstractNodeProxy implements Observer {

	public static final Object PLACEMENT_CHANGED = new Object();
	protected static final Object COLLECT_CONNECTIONS = new Object();

	private String componentName;
	private AbstractNodeProxy parent;

	public ComponentProxy(String componentName, AbstractNodeProxy parent) {
		this.componentName = componentName;
		this.parent = parent;
		parent.addObserver(this);
	}

	protected AbstractNodeProxy getParent() {
		return parent;
	}

	@Override
	protected String buildDiagramName() {
		String parentName = parent.buildDiagramName();
		if (parentName.length() == 0)
			return componentName;
		else
			return parentName + "." + componentName;
	}

	@Override
	protected InstComponentDecl getComponentDecl() {
		return parent.getInstComponentDecl(componentName);
	}

	@Override
	protected InstClassDecl getClassDecl() {
		return getComponentDecl().syncMyInstClass();
	}

	@Override
	protected InstNode getASTNode() {
		return getComponentDecl();
	}

	@Override
	protected boolean inDiagram() {
		return false;
	}

	@Override
	protected InstComponentDecl getInstComponentDecl(String componentName) {
		return getComponentDecl().syncSimpleLookupInstComponentDecl(
				componentName);
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
		return getComponentDecl().syncGetPlacement();
	}

	@Override
	public Layer getLayer() {
		return getComponentDecl().syncGetIconLayer();
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

	public List<ParameterProxy> getParameters() {
		List<ParameterProxy> parameters = new ArrayList<ParameterProxy>();
		collectParameters(getComponentDecl(), parameters);
		return parameters;
	}

	private void collectParameters(InstNode node,
			List<ParameterProxy> parameters) {
		for (InstExtends ie : node.syncGetInstExtendss()) {
			collectParameters(ie, parameters);
		}
		for (InstComponentDecl icd : node.syncGetInstComponentDecls()) {
			if (icd.syncIsPrimitive() && icd.syncIsParameter()) {
				parameters.add(new ParameterProxy(icd.syncName(), this));
			}
		}

	}

	@Override
	protected void setParameterValue(Stack<String> path, String value) {
		path.push(componentName);
		getParent().setParameterValue(path, value);
	}

	public void setComponentName(String newName) {
		componentName = newName;
	}

}
