package org.jmodelica.ide.graphical.editparts.primitives;


import org.eclipse.gef.EditPolicy;
import org.eclipse.gef.Request;
import org.eclipse.gef.commands.Command;
import org.eclipse.gef.editparts.AbstractGraphicalEditPart;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;
import org.jmodelica.icons.primitives.GraphicItem;
import org.jmodelica.ide.graphical.commands.RotateGraphicItemCommand;
import org.jmodelica.ide.graphical.editparts.AbstractIconEditPart;
import org.jmodelica.ide.graphical.editparts.RotationEditPolicy;
import org.jmodelica.ide.graphical.util.Transform;



public abstract class GraphicEditPart extends AbstractGraphicalEditPart implements Observer {
	
	private Transform transform;
	
	public GraphicEditPart(GraphicItem model) {
		setModel(model);
	}
	
	@Override
	public GraphicItem getModel() {
		return (GraphicItem) super.getModel();
	}
	
	protected Transform getTransform() {
		if (transform == null) {
			transform = ((AbstractIconEditPart) getParent()).getTransform();
			transform.translate(Transform.yInverter.transform(getModel().getOrigin()));
			transform.rotate(-getModel().getRotation() * Math.PI / 180);
		}
		return transform.clone();
	}
	
	public void invalidateTransform() {
		transform = null;
		transformInvalid();
	}
	
	protected abstract void transformInvalid();
	
	@Override
	public void addNotify() {
		updateOrigin();
		updateRotation();
		updateVisible();
		super.addNotify();
	}
	
	@Override
	public void activate() {
		super.activate();
		getModel().addObserver(this);
	}
	
	@Override
	public void deactivate() {
		super.deactivate();
		getModel().removeObserver(this);
	}
	
	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getModel()) {
			if (flag == GraphicItem.VISIBLE_UPDATED)
				updateVisible();
			else if (flag == GraphicItem.ROTATION_UPDATED)
				updateRotation();
			else if (flag == GraphicItem.ORIGIN_UPDATED)
				updateOrigin();
		}
	}
	
	private void updateVisible() {
		getFigure().setVisible(getModel().isVisible());
	}
	
	private void updateRotation() {
		invalidateTransform();
	}
	
	private void updateOrigin() {
		invalidateTransform();
	}

	@Override
	protected void createEditPolicies() {
		installEditPolicy(EditPolicy.COMPONENT_ROLE, new RotationEditPolicy() {

			@Override
			protected Command createRotateCommand(Request request, double angle) {
				return new RotateGraphicItemCommand(getModel(), angle);
			}
			
		});
	}
	
}
