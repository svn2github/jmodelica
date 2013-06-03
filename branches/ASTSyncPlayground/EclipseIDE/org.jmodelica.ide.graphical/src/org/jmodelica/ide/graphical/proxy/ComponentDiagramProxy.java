package org.jmodelica.ide.graphical.proxy;

import java.util.List;
import java.util.Stack;

import org.jastadd.ed.core.model.IASTPathPart;
import org.jmodelica.icons.Layer;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.icons.primitives.GraphicItem;

public class ComponentDiagramProxy extends AbstractDiagramProxy {

	private ComponentProxy component;

	public ComponentDiagramProxy(ComponentProxy component) {
		this.component = component;
	}

	@Override
	protected Stack<IASTPathPart> getASTPath() {
		return component.getASTPath();
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
	protected void setParameterValue(Stack<IASTPathPart> componentASTPath,
			Stack<String> path, String value) {
		component.setParameterValue(componentASTPath, path, value);
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

	@Override
	public Layer getLayer() {
		return component.getDiagramLayer();
	}

	@Override
	public String syncGetClassIconName() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public List<ComponentProxy> getComponents() {
		return component.getComponents();
	}

	@Override
	public List<GraphicItem> getGraphics() {
		return component.getGraphics();
	}

	@Override
	public String getComponentName() {
		return component.getComponentName();
	}
}