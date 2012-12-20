package org.jmodelica.icons.primitives;

import java.util.ArrayList;

import org.jmodelica.icons.coord.Extent;
import org.jmodelica.icons.coord.Point;



public class Polygon extends FilledShape {
	
	public static final Object POINTS_CHANGED = new Object();
	public static final Object SMOOTH_CHANGED = new Object();
	
	private ArrayList<Point> points;
	private Types.Smooth smooth;
	
	public static final Types.Smooth DEFAULT_SMOOTH = Types.Smooth.NONE;
	 
	public Polygon() {
		this(new ArrayList<Point>());
	}
	public Polygon(ArrayList<Point> points) {
		super();
		setSmooth(DEFAULT_SMOOTH);
		setPoints(points);
	}

	public void setPoints(ArrayList<Point> newPoints) {
		if (newPoints.size() != 0 && !newPoints.get(0).equals(newPoints.get(newPoints.size() - 1))) 
			newPoints.add(newPoints.get(0));
		points = newPoints;
		notifyObservers(POINTS_CHANGED);
	}

	public ArrayList<Point> getPoints() {
		return points;
	}

	public void setSmooth(Types.Smooth newSmooth) {
		if (smooth == newSmooth)
			return;
		smooth = newSmooth;
		notifyObservers(SMOOTH_CHANGED);
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
		return Point.calculateExtent(points);
	}
}