package org.jmodelica.icons;



public class Ellipse extends FilledRectShape {
	
	private double startAngle;
	private double endAngle;
	
	private static final double DEFAULT_START_ANGLE = 0;
	private static final double DEFAULT_END_ANGLE = 360;
	
	public Ellipse() {
		super(Extent.NO_EXTENT);
		startAngle = DEFAULT_START_ANGLE;
		endAngle = DEFAULT_END_ANGLE;
	}
	public Ellipse(Extent extent) {
		super(extent);
		startAngle = DEFAULT_START_ANGLE;
		endAngle = DEFAULT_END_ANGLE;
	}
	public void setStartAngle(double startAngle) {
		this.startAngle = startAngle;
	}

	public double getStartAngle() {
		return startAngle;
	}

	public void setEndAngle(double endAngle) {
		this.endAngle = endAngle;
	}

	public double getEndAngle() {
		return endAngle;
	}
	
	public String toString() {
		return super.toString();
	}
}