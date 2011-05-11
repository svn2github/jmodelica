package org.jmodelica.icons.mls;

import org.jmodelica.icons.mls.primitives.Extent;
import org.jmodelica.icons.mls.primitives.Point;

public class Transformation {
	private Point origin;
	private Extent extent;
	private double rotation;
	
	private static final Point DEFAULT_ORIGIN = new Point(0, 0);
	private static final double DEFAULT_ROTATION = 0;
	
	public Transformation(Extent extent, Point origin, double rotation) {
		this.extent = extent;
		this.origin = origin;
		this.rotation = rotation;
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
	
	public void setOrigin(Point origin) {
		//System.out.println("Sätter origin.");
		this.origin = origin;
	}
	
	public Extent getExtent() {
		return extent;
	}
	
	public void setExtent(Extent extent) {
		//System.out.println("Sätter extent.");
		this.extent = extent;
	}
	
	public double getRotation() {
		return rotation;
	}
	
	public void setRotation(double rotation) {
		//System.out.println("Sätter rotation.");
		this.rotation = rotation;
	}
	
	public String toString() {
		String s = "";
		s += "extent = " + extent;
		s += "\norigin = " + origin;
		s += "\nrotation = " + rotation;
		return s;
	}
}