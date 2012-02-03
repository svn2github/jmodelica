package org.jmodelica.icons.coord;

import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;

public class Placement extends Observable implements Observer {
	
	public static final Object VISIBLE_UPDATED = new Object();
	public static final Object TRANSFORMATION_UPDATED = new Object();
	public static final Object TRANSFORMATION_SWAPPED = new Object();

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
		notifyObservers(VISIBLE_UPDATED);
	}

	public Transformation getTransformation() {
		return transformation;
	}

	//TODO: shouldn't it be called setTransformation, since placement has nothing to do with icon...
	public void setIconTransformation(Transformation newTransformation) {
		if (transformation == newTransformation)
			return;
		if (transformation != null)
			transformation.removeObserver(this);
		this.transformation = newTransformation;
		if (newTransformation != null)
			newTransformation.addObserver(this);
		notifyObservers(TRANSFORMATION_SWAPPED);
	}

	public String toString() {
		String s = "";
		s += "visible = " + visible;
		s += "\ntransformation = " + transformation;
		return s;
	}

	@Override
	public void update(Observable o, Object flag) {
		if (o == transformation && (flag == Transformation.EXTENT_CHANGED || flag == Transformation.EXTENT_SWAPPED || flag == Transformation.ORIGIN_CHANGED || flag == Transformation.ORIGIN_SWAPPED || flag == Transformation.ROTATION_CHANGED))
			notifyObservers(TRANSFORMATION_UPDATED);
		else
			o.removeObserver(this);
	}
}