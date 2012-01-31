package org.jmodelica.icons.coord;

import org.jmodelica.icons.listeners.Observable;
import org.jmodelica.icons.listeners.PointListener;

public class Point extends Observable<PointListener> {
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
		for (PointListener l : getListeners())
			l.pointYCordUpdated(this);
	}

	public double getY() {
		return y;
	}

	public void setX(double newX) {
		if (x == newX)
			return;
		x = newX;
		for (PointListener l : getListeners())
			l.pointXCordUpdated(this);
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