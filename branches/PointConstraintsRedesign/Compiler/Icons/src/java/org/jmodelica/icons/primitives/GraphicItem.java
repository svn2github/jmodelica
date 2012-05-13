package org.jmodelica.icons.primitives;

import org.jmodelica.icons.Observable;
import org.jmodelica.icons.coord.Extent;
import org.jmodelica.icons.coord.Point;

public abstract class GraphicItem extends Observable {
	
	public static final Object VISIBLE_UPDATED = new Object();
	public static final Object ORIGIN_UPDATED = new Object();
	public static final Object ROTATION_UPDATED = new Object();
	
	protected boolean visible;
	protected Point origin;
	protected double rotation;
	
	public static final boolean DEFAULT_VISIBLE = true;
	public static final Point DEFAULT_ORIGIN = new Point(0, 0);
	public static final double DEFAULT_ROTATION = 0;

	public GraphicItem(boolean visible, Point origin, double rotation) {
		setVisible(visible);
		setOrigin(origin);
		setRotation(rotation);
	}
	
	public GraphicItem() {
		this(DEFAULT_VISIBLE, DEFAULT_ORIGIN, DEFAULT_ROTATION);
	}
	
	public GraphicItem(boolean visible) {
		this(visible, DEFAULT_ORIGIN, DEFAULT_ROTATION);
	}
	
	public GraphicItem(Point origin) {
		this(DEFAULT_VISIBLE, origin, DEFAULT_ROTATION);
	}

	public GraphicItem(double rotation) {
		this(DEFAULT_VISIBLE, DEFAULT_ORIGIN, rotation);
	}
	
	public GraphicItem(boolean visible, Point origin) {
		this(visible, origin, DEFAULT_ROTATION);
	}

	public GraphicItem(boolean visible, double rotation) {
		this(visible, DEFAULT_ORIGIN, rotation);
	}	

	public GraphicItem(Point origin, double rotation) {
		this(DEFAULT_VISIBLE, origin, rotation);
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
	
	public Point getOrigin() {
		return origin;
	}
	
	public void setOrigin(Point newOrigin) {
		if (origin == newOrigin)
			return;
		origin = newOrigin;
		notifyObservers(ORIGIN_UPDATED);
	}
	
	public double getRotation() {
		return rotation;
	}
	
	public void setRotation(double newRotation) {
		if (rotation == newRotation)
			return;
		rotation = newRotation;
		notifyObservers(ROTATION_UPDATED);
	}
	
	public abstract Extent getBounds();
	
	public String toString() {
		return "";
	}
	
}