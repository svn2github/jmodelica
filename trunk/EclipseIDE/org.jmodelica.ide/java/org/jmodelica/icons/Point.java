package org.jmodelica.icons;



public class Point
{
	private double x; 
	private double y;
	
	public Point() {
		x = 0;
		y = 0;
	}
	public Point(double x, double y) {	
		this.x = x;
		this.y = y;
	}
	public void setY(double y) {
		this.y = y;
	}
	public double getY() {
		return y;
	}
	public void setX(double x) {
		this.x = x;
	}
	public double getX() {
		return x;
	}
	
	public Point clone() {
		return new Point(x, y);
	}

	public String toString() {
		return "{" + x + "},{" + y + "}";
	}
}