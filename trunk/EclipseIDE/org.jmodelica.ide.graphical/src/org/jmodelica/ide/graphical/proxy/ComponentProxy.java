package org.jmodelica.ide.graphical.proxy;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;
import org.jmodelica.icons.coord.Extent;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.icons.coord.Transformation;
import org.jmodelica.ide.graphical.util.Transform;
import org.jmodelica.modelica.compiler.InstBaseClassDecl;
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
	protected InstComponentDecl getComponentDecl() {
		return parent.getInstComponentDecl(componentName);
	}

	@Override
	protected InstClassDecl getClassDecl() {
		return getComponentDecl().myInstClass();
	}

	@Override
	protected InstNode getASTNode() {
		return getComponentDecl();
	}

	public List<ConnectorProxy> getConnectors() {
		List<ConnectorProxy> connectors = new ArrayList<ConnectorProxy>();
		collectConnectors(getComponentDecl(), connectors);
		return connectors;

	}

	@Override
	protected boolean inDiagram() {
		return false;
	}

	private void collectConnectors(InstNode node, List<ConnectorProxy> connectors) {
		for (InstExtends ie : node.getInstExtendss()) {
			collectConnectors(ie, connectors);
		}
		for (InstComponentDecl icd : node.getInstComponentDecls()) {
			InstClassDecl classDecl = icd.myInstClass();
			if (classDecl.isKnown() && classDecl instanceof InstBaseClassDecl && !icd.getComponentDecl().isProtected() && icd.isConnector()) {
				ComponentProxy cp = getComponentMap().get(icd.qualifiedName());
				if (cp == null) {
					cp = new IconConnectorProxy(icd.name(), this);
					getComponentMap().put(icd.qualifiedName(), cp);
				}
				connectors.add((ConnectorProxy) cp);
			}
		}
	}

	@Override
	protected InstComponentDecl getInstComponentDecl(String componentName) {
		return getComponentDecl().simpleLookupInstComponentDecl(componentName);
	}

	public Transform calculateTransform(Transform parent) { //TODO:refactor
		// Based on org.jmodelica.icons.drawing.AWTIconDrawer.setTransformation()
		Transformation compTransformation = getPlacement().getTransformation();
		Extent transformationExtent = compTransformation.getExtent();
		Extent componentExtent = getComponentDecl().getCoordinateSystem().getExtent();
		Transform t = parent.clone();
		t.translate(Transform.yInverter.transform(compTransformation.getOrigin()));
//		componentTransform = transform.clone();
		t.translate(Transform.yInverter.transform(transformationExtent.getMiddle()));

		if (transformationExtent.getP2().getX() < transformationExtent.getP1().getX()) {
			t.scale(-1.0, 1.0);
//			componentTransform.scale(-1.0, 1.0);
		}
		if (transformationExtent.getP2().getY() < transformationExtent.getP1().getY()) {
			t.scale(1.0, -1.0);
//			componentTransform.scale(1.0, -1.0);
		}

		double angle = -compTransformation.getRotation() * Math.PI / 180;
		t.rotate(angle);
//		componentTransform.rotate(angle);

		t.scale(transformationExtent.getWidth() / componentExtent.getWidth(), transformationExtent.getHeight() / componentExtent.getHeight());

		return t;
	}

	public Transform calculateComponentTransform(Transform parent) { //TODO: refactor together with calculateTransform();
		Transformation compTransformation = getPlacement().getTransformation();
		Extent transformationExtent = compTransformation.getExtent();
		Transform t = parent.clone();
		t.translate(Transform.yInverter.transform(compTransformation.getOrigin()));
		if (transformationExtent.getP2().getX() < transformationExtent.getP1().getX()) {
			t.scale(-1.0, 1.0);
		}
		if (transformationExtent.getP2().getY() < transformationExtent.getP1().getY()) {
			t.scale(1.0, -1.0);
		}

		double angle = -compTransformation.getRotation() * Math.PI / 180;
		t.rotate(angle);

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
		return getComponentDecl().getPlacement();
	}

	public void setPlacement(Placement placement) {
		getComponentDecl().annotation().savePlacement(placement);
		notifyObservers(PLACEMENT_CHANGED);
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

}
