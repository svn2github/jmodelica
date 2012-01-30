package org.jmodelica.icons.primitives;

import org.jmodelica.icons.coord.Extent;
import org.jmodelica.icons.coord.Point;

public abstract class GraphicItem {
	
	protected boolean visible;
	protected Point origin;
	protected double rotation;
	
	private static final boolean DEFAULT_VISIBLE = true;
	private static final Point DEFAULT_ORIGIN = new Point(0, 0);
	private static final double DEFAULT_ROTATION = 0;

	public GraphicItem(boolean visible, Point origin, double rotation) {
		this.visible = visible;
		this.origin = origin;
		this.rotation = rotation;
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
	
	public void setVisible(boolean visible) {
		this.visible = visible;
	}
	
	public Point getOrigin() {
		return origin;
	}
	
	public void setOrigin(Point origin) {
		this.origin = origin;
	}
	
	public double getRotation() {
		return rotation;
	}
	
	public void setRotation(double rotation) {
		this.rotation = rotation;
	}
	
	public abstract Extent getBounds();
	
	public String toString() {
		return "";
	}
}