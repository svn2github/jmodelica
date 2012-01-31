package org.jmodelica.icons.coord;

import org.jmodelica.icons.listeners.Observable;
import org.jmodelica.icons.listeners.PlacementListener;
import org.jmodelica.icons.listeners.TransformationListener;

public class Placement extends Observable<PlacementListener> implements TransformationListener {

	private boolean visible;
	private Transformation transformation;

	private static final boolean DEFAULT_VISIBLE = true;

	/**
	 * @param transformation Placement in the diagram layer.
	 */
	public Placement(boolean visible, Transformation transformation) {
		setVisible(visible);
		setIconTransformation(transformation);
	}

	/**
	 * @param transformation Placement in the diagram layer.
	 */
	public Placement(Transformation transformation) {
		this(DEFAULT_VISIBLE, transformation);
	}

	public boolean isVisible() {
		return visible;
	}

	public void setVisible(boolean newVisible) {
		if (visible == newVisible)
			return;
		visible = newVisible;
		notifyVisibleChange();
	}

	public Transformation getTransformation() {
		return transformation;
	}

	//TODO: shouldn't it be called setTransformation, since placement has nothing to do with icon...
	public void setIconTransformation(Transformation newTransformation) {
		if (transformation != null && transformation.equals(newTransformation))
			return;
		if (transformation != null)
			transformation.removeListener(this);
		this.transformation = newTransformation;
		if (newTransformation != null)
			newTransformation.addlistener(this);
		notifyTransformationChange();
	}

	public String toString() {
		String s = "";
		s += "visible = " + visible;
		s += "\ntransformation = " + transformation;
		return s;
	}

	@Override
	public void transformationOriginChanged(Transformation t) {
		if (t != transformation)
			return;
		notifyTransformationChange();
	}

	@Override
	public void transformationExtentChanged(Transformation t) {
		if (t != transformation)
			return;
		notifyTransformationChange();
	}

	@Override
	public void transformationRotationChanged(Transformation t) {
		if (t != transformation)
			return;
		notifyTransformationChange();
	}

	private void notifyVisibleChange() {
		for (PlacementListener l : getListeners())
			l.placementVisibleChange(this);
	}

	private void notifyTransformationChange() {
		for (PlacementListener l : getListeners())
			l.placementTransformationChange(this);
	}
}