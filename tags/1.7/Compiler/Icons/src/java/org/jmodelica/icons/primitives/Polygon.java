package org.jmodelica.icons.primitives;

import java.util.ArrayList;

import org.jmodelica.icons.coord.Extent;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.primitives.Types.Smooth;



public class Polygon extends FilledShape {
	
	private ArrayList<Point> points;
	private Types.Smooth smooth;
	
	private static final Types.Smooth DEFAULT_SMOOTH = Types.Smooth.NONE;
	 
	public Polygon()
	{
		super();
		smooth = DEFAULT_SMOOTH;
		points = new ArrayList<Point>();
	}
	public Polygon(ArrayList<Point> points) {
		super();
		setPoints(points);
	}

	public void setPoints(ArrayList<Point> points) {
		this.points = points;
		int n = points.size();
		if (!points.get(0).equals(points.get(n - 1))) 
			points.add(points.get(0));
	}

	public ArrayList<Point> getPoints() {
		return points;
	}

	public void setSmooth(Types.Smooth smooth) {
		this.smooth = smooth;
	}
	public Types.Smooth getSmooth() {
		return smooth;
	}
	public String toString() {
		String s = "";
		for (int i = 0; i < points.size(); i++) {
			s += "\nP" + i + " = " + points.get(i);
		}
		return s+super.toString();
	}
	
	/**
	 * Returns the smallest possible extent that contains all of the polygon's points.
	 * @return
	 */
	public Extent getBounds() {
		Point p = points.get(0);
		Point min = new Point(p.getX(), p.getY());
		Point max = new Point(p.getX(), p.getY());
		for (Point point : points) {
			if (point.getX() < min.getX()) {
				min.setX(point.getX());
			} else if (point.getX() > max.getX()) {
				max.setX(point.getX());
			}
			if (point.getY() < min.getY()) {
				min.setY(point.getY());
			} else if (point.getY() > max.getY()) {
				max.setY(point.getY());
			}
		}
		Extent extent = new Extent(min, max);
		return extent;
	}
}