package org.jmodelica.icons.coord;

import org.jmodelica.icons.Observable;

public class Point extends Observable {
	
	/**
	 * Sent to observers when the point is moved in x.
	 */
	public static final Object X_UPDATED = new Object();
	
	/**
	 * Sent to observers when the point is moved in y.
	 */
	public static final Object Y_UPDATED = new Object();
	
	private double x;
	private double y;

	public Point() {
		this(0, 0);
	}

	public Point(double x, double y) {
		setX(x);
		setY(y);
	}

	public void setY(double newY) {
		if (y == newY)
			return;
		y = newY;
		notifyObservers(Y_UPDATED);
	}

	public double getY() {
		return y;
	}

	public void setX(double newX) {
		if (x == newX)
			return;
		x = newX;
		notifyObservers(X_UPDATED);
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