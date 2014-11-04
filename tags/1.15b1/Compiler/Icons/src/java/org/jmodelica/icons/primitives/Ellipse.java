package org.jmodelica.icons.primitives;

import org.jmodelica.icons.coord.Extent;



public class Ellipse extends FilledRectShape {
	
	public static final Object START_ANGLE_CHANGED = new Object();
	public static final Object END_ANGLE_CHANGED = new Object();
	
	private double startAngle;
	private double endAngle;
	
	public static final double DEFAULT_START_ANGLE = 0;
	public static final double DEFAULT_END_ANGLE = 360;
	
	public Ellipse() {
		this(Extent.NO_EXTENT);
	}
	public Ellipse(Extent extent) {
		super(extent);
		setStartAngle(DEFAULT_START_ANGLE);
		setEndAngle(DEFAULT_END_ANGLE);
	}
	public void setStartAngle(double newStartAngle) {
		if (startAngle == newStartAngle)
			return;
		startAngle = newStartAngle;
		notifyObservers(START_ANGLE_CHANGED);
	}

	public double getStartAngle() {
		return startAngle;
	}

	public void setEndAngle(double newEndAngle) {
		if (endAngle == newEndAngle)
			return;
		endAngle = newEndAngle;
		notifyObservers(END_ANGLE_CHANGED);
	}

	public double getEndAngle() {
		return endAngle;
	}
	
	public String toString() {
		return super.toString();
	}
}