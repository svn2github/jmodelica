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

	public static Point midPoint(Point a, Point b) {
		return new Point((a.x + b.x) / 2, (b.y + b.y) / 2);
	}

	public boolean equals(Object obj) {
		if (!(obj instanceof Point))
			return false;
		Point p = (Point) obj;
		return x == p.x && y == p.y;
	}
	
	public String toString() {
		return "{" + x + "},{" + y + "}";
	}
	
}