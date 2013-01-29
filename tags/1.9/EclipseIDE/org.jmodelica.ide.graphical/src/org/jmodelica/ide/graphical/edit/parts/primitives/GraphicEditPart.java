package org.jmodelica.ide.graphical.edit.parts.primitives;

import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;
import org.jmodelica.icons.primitives.GraphicItem;
import org.jmodelica.ide.graphical.edit.parts.AbstractInstNodePart;
import org.jmodelica.ide.graphical.edit.parts.AbstractModelicaPart;
import org.jmodelica.ide.graphical.util.Transform;

public abstract class GraphicEditPart extends AbstractModelicaPart implements Observer {

	public GraphicEditPart(GraphicItem model) {
		super(model);
	}

	@Override
	public GraphicItem getModel() {
		return (GraphicItem) super.getModel();
	}

	@Override
	public AbstractInstNodePart getParent() {
		return (AbstractInstNodePart) super.getParent();
	}

	@Override
	protected Transform calculateTransform() {
		Transform transform = getParent().getTransform();
		transform.translate(Transform.yInverter.transform(getModel().getOrigin()));
		transform.rotate(-getModel().getRotation() * Math.PI / 180);
		return transform;
	}
	
	@Override
	public void addNotify() {
		updateOrigin();
		updateRotation();
		updateVisible();
		super.addNotify();
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
		super.update(o, flag, additionalInfo);
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
//		installEditPolicy(EditPolicy.COMPONENT_ROLE, new RotationEditPolicy() {
//
//			@Override
//			protected Command createRotateCommand(Request request, double angle) {
//				return new RotateGraphicItemCommand(getModel(), angle);
//			}
//			
//		});
	}

}
