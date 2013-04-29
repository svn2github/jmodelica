package org.jmodelica.ide.graphical.proxy;

import java.util.Stack;

import org.jmodelica.icons.coord.Placement;
import org.jmodelica.ide.graphical.proxy.cache.CachedInstClassDecl;
import org.jmodelica.ide.graphical.proxy.cache.CachedInstComponentDecl;
import org.jmodelica.ide.graphical.proxy.cache.CachedInstNode;

public class ComponentDiagramProxy extends AbstractDiagramProxy {

	private ComponentProxy component;

	public ComponentDiagramProxy(ComponentProxy component) {
		this.component = component;
	}

	@Override
	public String getQualifiedClassName() {
		return component.getQualifiedClassName();
	}

	@Override
	protected CachedInstNode getCachedASTNode() {
		return component.getComponentDecl();
	}

	@Override
	protected CachedInstClassDecl getClassDecl() {
		return null;
	}

	@Override
	protected CachedInstComponentDecl getComponentDecl() {
		return component.getComponentDecl();
	}

	@Override
	public void addComponent(String className, String componentName,
			Placement placement, int undoActionId) {
		throw new UnsupportedOperationException(
				"It is not possible to alter component definition!");
	}

	@Override
	public void removeComponent(ComponentProxy component, int undoActionId) {
		throw new UnsupportedOperationException(
				"It is not possible to alter component definition!");
	}

	@Override
	public void addConnection(String sourceDiagramName,
			String targetDiagramName, int undoActionId) {
		throw new UnsupportedOperationException(
				"It is not possible to alter component definition!");
	}

	@Override
	protected void addConnection(ConnectionProxy connection, int undoActionId) {
		throw new UnsupportedOperationException(
				"It is not possible to alter component definition!");
	}

	@Override
	public void removeConnection(ConnectionProxy connection, int undoActionId) {
		throw new UnsupportedOperationException(
				"It is not possible to alter component definition!");
	}

	@Override
	protected void setParameterValue(CachedInstComponentDecl comp, Stack<String> path, String value) {
		component.setParameterValue(comp, path, value);
	}

	@Override
	public void moveComponent(ComponentProxy component, double x, double y) {
		throw new UnsupportedOperationException(
				"It is not possible to alter component definition!");
	}

	@Override
	public void rotateComponent(ComponentProxy component, double angle) {
		throw new UnsupportedOperationException(
				"It is not possible to alter component definition!");
	}

	@Override
	public void resizeComponent(ComponentProxy component, double x, double y,
			double x2, double y2) {
		throw new UnsupportedOperationException(
				"It is not possible to alter component definition!");
	}

	@Override
	public void addBendPoint(ConnectionProxy connection, double x, double y,
			int index) {
		throw new UnsupportedOperationException(
				"It is not possible to alter component definition!");
	}

	@Override
	public void removeBendPoint(ConnectionProxy connection, int index) {
		throw new UnsupportedOperationException(
				"It is not possible to alter component definition!");
	}

	@Override
	public void moveBendPoint(ConnectionProxy connection, double x, double y,
			int index) {
		throw new UnsupportedOperationException(
				"It is not possible to alter component definition!");
	}

}
