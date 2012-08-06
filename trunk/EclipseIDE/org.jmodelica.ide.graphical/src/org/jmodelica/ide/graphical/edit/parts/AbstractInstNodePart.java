package org.jmodelica.ide.graphical.edit.parts;

import java.util.List;

import org.eclipse.gef.editparts.AbstractGraphicalEditPart;
import org.jmodelica.icons.Icon;
import org.jmodelica.icons.Layer;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;
import org.jmodelica.icons.primitives.Color;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.ide.graphical.edit.parts.primitives.AbstractPolygonEditPart;
import org.jmodelica.ide.graphical.edit.parts.primitives.GraphicEditPart;
import org.jmodelica.ide.graphical.proxy.AbstractNodeProxy;
import org.jmodelica.ide.graphical.util.ASTNodeResourceProvider;
import org.jmodelica.ide.graphical.util.Transform;
import org.jmodelica.modelica.compiler.InstExtends;
import org.jmodelica.modelica.compiler.InstNode;

public abstract class AbstractInstNodePart extends AbstractGraphicalEditPart implements ASTNodeResourceProvider, Observer {

	private Transform transform;

	public AbstractInstNodePart(AbstractNodeProxy anp) {
		setModel(anp);
	}

	@Override
	public AbstractNodeProxy getModel() {
		return (AbstractNodeProxy) super.getModel();
	}

	@Override
	public void activate() {
		super.activate();
		getModel().addObserver(this);
	}

	@Override
	public void deactivate() {
		getModel().removeObserver(this);
		super.deactivate();
	}

	public Transform getTransform() {
		if (transform == null)
			transform = calculateTransform();
		return transform;
	}

	protected abstract Transform calculateTransform();

	public void invalidateTransform() {
		transform = null;

		for (Object o : getChildren()) {
			if (o instanceof GraphicEditPart)
				((GraphicEditPart) o).invalidateTransform();
			if (o instanceof AbstractInstNodePart)
				((AbstractInstNodePart) o).invalidateTransform();
		}
		refreshVisuals();
	}

	protected static void collectGraphics(InstNode node, List<Object> graphics, boolean inDiagram) {
		Icon icon = inDiagram ? node.diagram() : node.icon();
		if (icon.getLayer() != Layer.NO_LAYER)
			graphics.addAll(icon.getLayer().getGraphics());
		for (InstExtends ie : node.getInstExtendss()) {
			collectGraphics(ie, graphics, inDiagram);
		}
	}

	public Color calculateConnectionColor() {
		for (Object o : getChildren()) {
			Color c = Line.DEFAULT_COLOR;
			if (o instanceof AbstractPolygonEditPart) {
				c = ((AbstractPolygonEditPart) o).getModel().getLineColor();
			} else if (o instanceof AbstractInstNodePart) {
				c = ((AbstractInstNodePart) o).calculateConnectionColor();
			}
			if (c != Line.DEFAULT_COLOR)
				return c;
		}
		return Line.DEFAULT_COLOR;
	}

	@Override
	public String getComponentName() {
		return getModel().getComponentName();
	}

	@Override
	public String getClassName() {
		return getModel().getClassName();
	}

	@Override
	public String getParameterValue(String parameter) {
		return getModel().getParameterValue(parameter);
	}

	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (!isActive())
			o.removeObserver(this);
	}
}
