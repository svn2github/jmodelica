package org.jmodelica.icons.coord;

import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;

public class Transformation extends Observable implements Observer {
	
	public static final Object ORIGIN_CHANGED = new Object();
	public static final Object ORIGIN_SWAPPED = new Object();
	public static final Object EXTENT_CHANGED = new Object();
	public static final Object EXTENT_SWAPPED = new Object();
	public static final Object ROTATION_CHANGED = new Object();
	
	private Point origin;
	private Extent extent;
	private double rotation;

	private static final Point DEFAULT_ORIGIN = new Point(0, 0);
	private static final double DEFAULT_ROTATION = 0;

	public Transformation(Extent extent, Point origin, double rotation) {
		setExtent(extent);
		setOrigin(origin);
		setRotation(rotation);
	}

	public Transformation() {
		this(Extent.NO_EXTENT, DEFAULT_ORIGIN, DEFAULT_ROTATION);
	}

	public Transformation(Extent extent) {
		this(extent, DEFAULT_ORIGIN, DEFAULT_ROTATION);
	}

	public Transformation(Extent extent, Point origin) {
		this(extent, origin, DEFAULT_ROTATION);
	}

	public Transformation(Extent extent, double rotation) {
		this(extent, DEFAULT_ORIGIN, rotation);
	}

	public Point getOrigin() {
		return origin;
	}

	public void setOrigin(Point newOrigin) {
		if (origin == newOrigin)
			return;
		if (origin != null)
			origin.removeObserver(this);
		origin = newOrigin;
		if (newOrigin != null)
			newOrigin.addObserver(this);
		notifyObservers(ORIGIN_SWAPPED);
	}

	public Extent getExtent() {
		return extent;
	}

	public void setExtent(Extent newExtent) {
		if (extent == newExtent)
			return;
		if (extent != null)
			extent.removeObserver(this);
		extent = newExtent;
		if (newExtent != null)
			newExtent.addObserver(this);
		notifyObservers(EXTENT_SWAPPED);
	}

	public double getRotation() {
		return rotation;
	}

	public void setRotation(double newRotation) {
		if (rotation == newRotation)
			return;
		rotation = newRotation;
		notifyObservers(ROTATION_CHANGED);
	}

	public String toString() {
		String s = "";
		s += "extent = " + extent;
		s += "\norigin = " + origin;
		s += "\nrotation = " + rotation;
		return s;
	}

	@Override
	public void update(Observable o, Object flag) {
		if (o == origin && (flag == Point.X_UPDATED || flag == Point.Y_UPDATED))
			notifyObservers(ORIGIN_CHANGED);
		else if (o == extent && (flag == Extent.P1_SWAPPED || flag == Extent.P1_UPDATED || flag == Extent.P2_SWAPPED || flag == Extent.P2_UPDATED))
			notifyObservers(EXTENT_CHANGED);
		else
			o.removeObserver(this);
	}

}