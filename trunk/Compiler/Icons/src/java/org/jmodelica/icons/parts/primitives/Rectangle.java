
package org.jmodelica.icons.parts.primitives;

import org.jmodelica.icons.parts.coord.Extent;
import org.jmodelica.icons.parts.primitives.Types.BorderPattern;


public class Rectangle extends FilledRectShape {
	
	private Types.BorderPattern borderPattern;
	private double radius;
	
	private static final Types.BorderPattern DEFAULT_BORDER_PATTERN = Types.BorderPattern.NONE;
	private static final float DEFAULT_RADIUS = 0;
	
	public Rectangle(){
		super(Extent.NO_EXTENT);
		borderPattern = DEFAULT_BORDER_PATTERN;
		radius = DEFAULT_RADIUS;
	}
	public void setBorderPattern(Types.BorderPattern borderPattern) {
		this.borderPattern = borderPattern;
	}

	public Types.BorderPattern getBorderPattern() {
		return borderPattern;
	}

	public void setRadius(double radius) {
		this.radius = radius;
	}

	public double getRadius() {
		return radius;
	}
	
	public String toString() {
		return super.toString();
	}
}

