package org.jmodelica.ide.graphical.edit.parts;

import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.geometry.Rectangle;
import org.eclipse.gef.EditPolicy;
import org.eclipse.gef.GraphicalEditPart;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.icons.coord.Transformation;
import org.jmodelica.ide.graphical.edit.policies.ComponentPolicy;
import org.jmodelica.ide.graphical.graphics.IconLayer;
import org.jmodelica.ide.graphical.proxy.ComponentProxy;
import org.jmodelica.ide.graphical.util.Converter;
import org.jmodelica.ide.graphical.util.Transform;

public class ComponentPart extends AbstractInstNodePart {

	public ComponentPart(ComponentProxy cp) {
		super(cp);
	}

	@Override
	public ComponentProxy getModel() {
		return (ComponentProxy) super.getModel();
	}

	@Override
	public AbstractInstNodePart getParent() {
		return (AbstractInstNodePart) super.getParent();
	}
	
	@Override
	protected IFigure createFigure() {
		return new IconLayer();
	}
	
	@Override
	public IconLayer getFigure() {
		return (IconLayer) super.getFigure();
	}
	
	@Override
	public void activate() {
		super.activate();
		Placement placement = getModel().getPlacement();
		placement.addObserver(this);
		placement.getTransformation().addObserver(this);
	}
	
	@Override
	public void addNotify() {
		super.addNotify();
		updateVisible();
	}
	
	@Override
	protected void refreshVisuals() {
		if (getFigure().isVisible()) {
			Rectangle declaredBounds = Converter.convert(getTransform().transform(Transform.yInverter.transform(getModel().getLayer().getCoordinateSystem().getExtent())));
			getFigure().setDeclaredBounds(declaredBounds);
			getFigure().figureMoved(null);
			((GraphicalEditPart) getParent()).setLayoutConstraint(this, getFigure(), getFigure().getBounds());
		}
	}
	
	@Override
	protected Transform calculateTransform() {
		return getModel().calculateTransform(getParent().getTransform());
	}

	@Override
	protected void createEditPolicies() {
		installEditPolicy(EditPolicy.COMPONENT_ROLE, new ComponentPolicy(this));
	}

	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		
		if (o == getModel().getPlacement()) {
			if (flag == Placement.VISIBLE_UPDATED)
				updateVisible();
		}
		if (o == getModel().getPlacement().getTransformation()) {
			if (flag == Transformation.ORIGIN_UPDATED)
				invalidateTransform();
			if (flag == Transformation.EXTENT_UPDATED)
				invalidateTransform();
			if (flag == Transformation.ROTATION_CHANGED)
				invalidateTransform();
		}
		
		super.update(o, flag, additionalInfo);
	}

	private void updateVisible() {
		getFigure().setVisible(getModel().getPlacement().isVisible());
	}

}
