package org.jmodelica.ide.graphical.editparts;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.gef.editparts.AbstractGraphicalEditPart;
import org.jmodelica.icons.Icon;
import org.jmodelica.icons.Layer;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;
import org.jmodelica.icons.coord.CoordinateSystem;
import org.jmodelica.ide.graphical.editparts.primitives.GraphicEditPart;
import org.jmodelica.ide.graphical.util.Transform;

public abstract class AbstractIconEditPart extends AbstractGraphicalEditPart implements Observer {

	private Transform transform;

	public AbstractIconEditPart(Object model) {
		setModel(model);
	}

	@Override
	public void activate() {
		super.activate();
		getIcon().addObserver(this);
		getIcon().getLayer().addObserver(this);
		getIcon().getLayer().getCoordinateSystem().addObserver(this);
	}

	@Override
	public void deactivate() {
		getIcon().removeObserver(this);
		getIcon().getLayer().removeObserver(this);
		getIcon().getLayer().getCoordinateSystem().removeObserver(this);
		setModel(null);
		super.deactivate();
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

	public abstract Icon getIcon();

	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getIcon()) {
			if (flag == Icon.SUBCOMPONENT_ADDED || flag == Icon.SUBCOMPONENT_REMOVED)
				refreshChildren();
			else if (flag == Icon.SUPERCLASS_ADDED || flag == Icon.SUPERCLASS_REMOVED)
				refreshChildren();
		} else if (o == getIcon().getLayer()) {
			if (flag == Layer.GRAPHICS_SWAPPED)
				refreshChildren();
		} else if (o == getIcon().getLayer().getCoordinateSystem()) {
			if (flag == CoordinateSystem.EXTENT_UPDATED)
				updateIconExtent();
			else if (flag == CoordinateSystem.GRID_CHANGED)
				updateGrid();
			else if (flag == CoordinateSystem.INITIAL_SCALE_CHANGED)
				updateInitialScale();
			else if (flag == CoordinateSystem.PRESERVE_ASPECT_RATIO_CHANGED)
				updatePreserveAspectRatio();
		}

	}

	protected void updateIconExtent() {
		invalidateTransform();
		refreshVisuals();
	}

	protected void updateGrid() {
		//Nothing to do here... yet...
	}

	protected void updateInitialScale() {
		//Nothing to do here... yet...
	}

	protected void updatePreserveAspectRatio() {
		//Nothing to do here... yet...
	}

	@Override
	protected List<Object> getModelChildren() {
		List<Object> list = new ArrayList<Object>();
		getSuperclassGraphics(getIcon(), list);
		getSuperclassComponents(getIcon(), list);
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

}