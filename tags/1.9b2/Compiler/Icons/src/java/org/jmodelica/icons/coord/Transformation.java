package org.jmodelica.icons.coord;

import org.jmodelica.icons.Observable;

public class Transformation extends Observable {
	
	public static final Object ORIGIN_UPDATED = new Object();
	public static final Object EXTENT_UPDATED = new Object();
	public static final Object ROTATION_CHANGED = new Object();
	
	private Point origin;
	private Extent extent;
	private double rotation;

	public static final Point DEFAULT_ORIGIN = new Point(0, 0);
	public static final Extent DEFAULT_EXTENT = new Extent(new Point(-10, -10), new Point(10, 10));
	public static final double DEFAULT_ROTATION = 0;

	public Transformation(Extent extent, Point origin, double rotation) {
		setExtent(extent);
		setOrigin(origin);
		setRotation(rotation);
	}

	public Transformation() {
		this(DEFAULT_EXTENT, DEFAULT_ORIGIN, DEFAULT_ROTATION);
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
		origin = newOrigin;
		notifyObservers(ORIGIN_UPDATED);
	}

	public Extent getExtent() {
		return extent;
	}

	public void setExtent(Extent newExtent) {
		if (extent == newExtent)
			return;
		extent = newExtent;
		notifyObservers(EXTENT_UPDATED);
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

}