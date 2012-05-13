package org.jmodelica.ide.graphical.editparts;

import java.util.ArrayList;
import java.util.List;


import org.eclipse.gef.editparts.AbstractGraphicalEditPart;
import org.jmodelica.icons.Icon;
import org.jmodelica.icons.Layer;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;
import org.jmodelica.ide.graphical.editparts.primitives.GraphicEditPart;
import org.jmodelica.ide.graphical.util.Transform;


public abstract class AbstractIconEditPart extends AbstractGraphicalEditPart implements Observer {

	private Transform transform;
	
	public AbstractIconEditPart(Icon model) {
		setModel(model);
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
	
	public Transform getTransform() {
		if (transform == null) {
			transform = calculateTransform();
		}
		return transform.clone();
	}
	
	protected void invalidateTransform() {
		transform = null;
		for (Object o : getChildren()) {
			if (o instanceof GraphicEditPart)
				((GraphicEditPart) o).invalidateTransform();
		}
	}
	
	protected abstract Transform calculateTransform();

	public Icon getModel() {
		return (Icon) super.getModel();
	}

	protected List<Object> getModelChildren() {
		List<Object> list = new ArrayList<Object>();
		getSuperclassGraphics(getModel(), list);
		getSuperclassComponents(getModel(), list);
		return list;
	}

	private static void getSuperclassGraphics(Icon icon, List<Object> list) {
		for (Icon superclass : icon.getSuperclasses()) {
			getSuperclassGraphics(superclass, list);
		}
		if (icon.getLayer() != Layer.NO_LAYER) {
			list.addAll(icon.getLayer().getGraphics());
		}
	}

	private static void getSuperclassComponents(Icon icon, List<Object> list) {
		for (Icon superclass : icon.getSuperclasses()) {
			getSuperclassComponents(superclass, list);
		}
		list.addAll(icon.getSubcomponents());
	}
	
	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getModel() && (flag == Icon.SUBCOMPONENT_ADDED || flag == Icon.SUBCOMPONENT_REMOVED))
			refreshChildren();
	}

}