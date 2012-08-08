package org.jmodelica.ide.graphical.edit.parts;

import java.util.List;

import org.eclipse.gef.editparts.AbstractGraphicalEditPart;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;
import org.jmodelica.icons.primitives.Color;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.ide.graphical.util.Transform;

public abstract class AbstractModelicaPart extends AbstractGraphicalEditPart implements Observer {

	private Transform transform;

	public AbstractModelicaPart(Observable model) {
		setModel(model);
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

	@Override
	public Observable getModel() {
		return (Observable) super.getModel();
	}

	@SuppressWarnings("unchecked")
	@Override
	public List<AbstractModelicaPart> getChildren() {
		return super.getChildren();
	}

	protected abstract Transform calculateTransform();

	protected abstract void transformInvalid();

	public final Transform getTransform() {
		if (transform == null)
			transform = calculateTransform();
		return transform.clone();
	}

	public final void invalidateTransform() {
		transform = null;
		for (AbstractModelicaPart part : getChildren())
			part.invalidateTransform();
		transformInvalid();
	}

	public Color calculateConnectionColor() {
		for (AbstractModelicaPart part : getChildren()) {
			Color c = part.calculateConnectionColor();
			if (c != Line.DEFAULT_COLOR)
				return c;
		}
		return Line.DEFAULT_COLOR;
	}

	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {}

}
