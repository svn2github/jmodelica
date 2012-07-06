package org.jmodelica.ide.graphical.util;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.draw2d.geometry.Point;
import org.eclipse.draw2d.geometry.PointList;
import org.eclipse.draw2d.geometry.Rectangle;
import org.eclipse.swt.graphics.Color;
import org.jmodelica.icons.coord.Extent;

public class Converter {

	public static Color convert(org.jmodelica.icons.primitives.Color color) {
		return new Color(null, color.getR(), color.getG(), color.getB());
	}

	public static Point convert(org.jmodelica.icons.coord.Point point) {
		return new Point((int)Math.round(point.getX()), (int)Math.round(point.getY()));
//		return new PrecisionPoint(point.getX(), point.getY());
	}

	public static org.jmodelica.icons.coord.Point convert(Point point) {
		return new org.jmodelica.icons.coord.Point(point.preciseX(), point.preciseY());
	}
	
	public static PointList convert(List<org.jmodelica.icons.coord.Point> points) {
		PointList convertedPoints = new PointList(points.size());
		for (org.jmodelica.icons.coord.Point p : points) {
			convertedPoints.addPoint(convert(p));
		}
		return convertedPoints;
	}

	public static List<org.jmodelica.icons.coord.Point> convert(PointList points) {
		List<org.jmodelica.icons.coord.Point> convertedPoints = new ArrayList<org.jmodelica.icons.coord.Point>(points.size());
		for (int i = 0; i < points.size(); i++) {
			convertedPoints.add(convert(points.getPoint(i)));
		}
		return convertedPoints;
	}

	public static Extent convert(Rectangle constraint) {
		return new Extent(convert(constraint.getTopLeft()), convert(constraint.getBottomRight()));
	}

	public static Rectangle convert(Extent extent) {
		return new Rectangle(convert(extent.getP1()), convert(extent.getP2()));
	}

}
