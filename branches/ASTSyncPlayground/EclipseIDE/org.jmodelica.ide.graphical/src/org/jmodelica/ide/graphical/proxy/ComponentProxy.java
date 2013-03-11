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
import org.jmodelica.ide.graphical.proxy.cache.CachedInstClassDecl;
import org.jmodelica.ide.graphical.proxy.cache.CachedInstComponentDecl;
import org.jmodelica.ide.graphical.proxy.cache.CachedInstExtends;
import org.jmodelica.ide.graphical.proxy.cache.CachedInstNode;
import org.jmodelica.ide.graphical.util.Transform;
import org.jmodelica.modelica.compiler.ASTNode;

public class ComponentProxy extends AbstractNodeProxy implements Observer {

	public static final Object PLACEMENT_CHANGED = new Object();
	protected static final Object COLLECT_CONNECTIONS = new Object();

	private String componentName;
	private AbstractNodeProxy parent;
	private CachedInstComponentDecl myInstCompDeclCached;

	public ComponentProxy(CachedInstComponentDecl icdc, String componentName,
			AbstractNodeProxy parent) {
		this.componentName = componentName;
		this.parent = parent;
		this.myInstCompDeclCached = icdc;
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
	protected CachedInstComponentDecl getComponentDecl() {
		return myInstCompDeclCached;
	}

	@Override
	protected CachedInstClassDecl getClassDecl() {
		return null; // TODO fail
		// return getComponentDecl().syncMyInstClass();
	}

	@Override
	protected CachedInstNode getASTNode() {
		return getComponentDecl();
	}

	@Override
	protected boolean inDiagram() {
		return false;
	}

	@Override
	protected CachedInstComponentDecl getInstComponentDecl(String componentName) {
		for (CachedInstComponentDecl icdc : getComponentDecl()
				.syncGetInstComponentDecls()) {
			if (icdc.syncName().equalsIgnoreCase(componentName)) {
				return icdc;
			}
		}
		for (CachedInstExtends iec : getComponentDecl().syncGetInstExtendss()) {
			for (CachedInstComponentDecl icdc : iec.syncGetInstComponentDecls()) {
				if (icdc.syncName().equalsIgnoreCase(componentName)) {
					return icdc;
				}
			}
		}
		return null;
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

	private void collectParameters(CachedInstNode node,
			List<ParameterProxy> parameters) {
		for (CachedInstExtends ie : node.syncGetInstExtendss()) {
			collectParameters(ie, parameters);
		}
		for (CachedInstComponentDecl icd : node.syncGetInstComponentDecls()) {
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

	public ASTNode<?> getRealASTNode() {
		// TODO Auto-generated method stub
		return null;
	}

}
