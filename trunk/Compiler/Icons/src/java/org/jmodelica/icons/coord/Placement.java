package org.jmodelica.icons.coord;

import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;

public class Placement extends Observable implements Observer {
	
	public static final Object VISIBLE_UPDATED = new Object();
	public static final Object TRANSFORMATION_UPDATED = new Object();
	public static final Object TRANSFORMATION_SWAPPED = new Object();

	private boolean visible;
	private Transformation transformation;
	
	public static final boolean DEFAULT_VISIBLE = true;
	
	/**
	 * @param transformation Placement in the diagram layer.
	 */
	public Placement(boolean visible, Transformation transformation) {
		setVisible(visible);
		setTransformation(transformation);
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

	public void setTransformation(Transformation newTransformation) {
		if (transformation == newTransformation)
			return;
		if (transformation != null)
			transformation.removeObserver(this);
		Transformation oldTransformation = transformation;
		this.transformation = newTransformation;
		if (newTransformation != null)
			newTransformation.addObserver(this);
		notifyObservers(TRANSFORMATION_SWAPPED, oldTransformation);
	}

	public String toString() {
		String s = "";
		s += "visible = " + visible;
		s += "\ntransformation = " + transformation;
		return s;
	}

	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == transformation && (flag == Transformation.EXTENT_UPDATED || flag == Transformation.ORIGIN_UPDATED || flag == Transformation.ROTATION_CHANGED))
			notifyObservers(TRANSFORMATION_UPDATED);
	}
}