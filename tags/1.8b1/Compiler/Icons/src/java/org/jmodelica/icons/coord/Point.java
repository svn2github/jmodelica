package org.jmodelica.icons.coord;

import java.util.List;

/**
 * 
 * A simple representation of a point in a plane. Uses double precision. This
 * object is immutable.
 * 
 */
public class Point {

	private double x;
	private double y;

	/**
	 * Constructs a point object with location (0, 0).
	 */
	public Point() {
		this(0, 0);
	}

	/**
	 * Constructs a point object with the location (<code>x</code>,
	 * <code>y</code>).
	 * 
	 * @param x X location of the point
	 * @param y Y location of the point
	 */
	public Point(double x, double y) {
		this.x = x;
		this.y = y;
	}

	/**
	 * Returns the y value of this point.
	 * 
	 * @return y value
	 */
	public double getY() {
		return y;
	}

	/**
	 * Returns the x value of this point.
	 * 
	 * @return x value
	 */
	public double getX() {
		return x;
	}

	/**
	 * @deprecated should't be used anymore since it's now immutable.
	 */
	@Deprecated
	public Point clone() {
		return new Point(x, y);
	}

	/**
	 * Calculates the point that lies between the two points <code>a</code> and
	 * <code>b</code>.
	 * 
	 * @param a First point
	 * @param b Second point
	 * @return point in between
	 */
	public static Point midPoint(Point a, Point b) {
		return new Point((a.x + b.x) / 2, (b.y + b.y) / 2);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Point))
			return false;
		Point p = (Point) obj;
		return x == p.x && y == p.y;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Object#toString()
	 */
	public String toString() {
		return "{" + x + "},{" + y + "}";
	}

	/**
	 * Calculates the smallest extent that will contain all points.
	 * 
	 * @param points Points to calculate extent from
	 * @return calculated extent
	 */
	public static Extent calculateExtent(List<Point> points) {
		if (points == null || points.size() == 0) {
			return null;
		}
		double minX = 0;
		double maxX = 0;
		double minY = 0;
		double maxY = 0;
		for (Point p : points) {
			if (p.getX() < minX)
				minX = p.getX();
			if (p.getX() > maxX)
				maxX = p.getX();
			if (p.getY() < minY)
				minY = p.getY();
			if (p.getY() > maxY)
				maxY = p.getY();
		}
		Extent extent = new Extent(new Point(minX, minY), new Point(maxX, maxY));
		return extent;
	}

}