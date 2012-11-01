
package org.jmodelica.icons.primitives;

import org.jmodelica.icons.coord.Extent;


public class Rectangle extends FilledRectShape {
	
	public static final Object BORDER_PATTERN_CHANGED = new Object();
	public static final Object RADIUS_CHANGED = new Object();
	
	
	private Types.BorderPattern borderPattern;
	private double radius;
	
	public static final Types.BorderPattern DEFAULT_BORDER_PATTERN = Types.BorderPattern.NONE;
	public static final float DEFAULT_RADIUS = 0;
	
	public Rectangle(){
		super(Extent.NO_EXTENT);
		setBorderPattern(DEFAULT_BORDER_PATTERN);
		setRadius(DEFAULT_RADIUS);
	}
	public void setBorderPattern(Types.BorderPattern newBorderPattern) {
		if (borderPattern == newBorderPattern)
			return;
		borderPattern = newBorderPattern;
		notifyObservers(BORDER_PATTERN_CHANGED);
	}

	public Types.BorderPattern getBorderPattern() {
		return borderPattern;
	}

	public void setRadius(double newRadius) {
		if (radius == newRadius)
			return;
		radius = newRadius;
		notifyObservers(RADIUS_CHANGED);
	}

	public double getRadius() {
		return radius;
	}
	
	public String toString() {
		return super.toString();
	}
}

