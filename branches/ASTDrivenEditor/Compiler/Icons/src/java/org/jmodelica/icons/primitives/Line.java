package org.jmodelica.icons.primitives;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;
import org.jmodelica.icons.coord.Extent;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.drawing.IconConstants;
import org.jmodelica.icons.primitives.Types.Arrow;
import org.jmodelica.icons.primitives.Types.FillPattern;


public class Line extends GraphicItem implements Observer {
	
	public static final Object POINTS_UPDATED = new Object();
	public static final Object COLOR_UPDATE = new Object();
	public static final Object COLOR_SWAPPED = new Object();
	public static final Object LINE_PATTERN_UPDATED = new Object();
	public static final Object THICKNESS_UPDATE = new Object();
	public static final Object ARROW_UPDATED = new Object();
	public static final Object ARROW_SIZE_UPDATED = new Object();
	public static final Object SMOOTH_UPDATED = new Object();
	
	
	private List<Point> points;
	private Color color;
	private Types.LinePattern linePattern;
	private double thickness;
	private Types.Arrow[] arrow;			// {start arrow, end arrow}
	private double arrowSize;
	private Polygon[] arrowPolygons;
	private Types.Smooth smooth;
	
	
	public static final Color DEFAULT_COLOR = Color.BLACK;
	public static final Types.LinePattern DEFAULT_LINE_PATTERN = Types.LinePattern.SOLID;
	public static final double DEFAULT_THICKNESS = 0.25;
	public static final Types.Arrow[] DEFAULT_ARROW = {Types.Arrow.NONE, Types.Arrow.NONE};
	public static final double DEFAULT_ARROW_SIZE = 3.0;
	public static final Types.Smooth DEFAULT_SMOOTH = Types.Smooth.NONE;

	public Line() {
		this(Collections.<Point>emptyList());
	}	
	
	public Line(List<Point> points) {
		super();
		setColor(DEFAULT_COLOR);
		setLinePattern(DEFAULT_LINE_PATTERN);
		setThickness(DEFAULT_THICKNESS);
		setArrowSize(DEFAULT_ARROW_SIZE);
		setArrow(DEFAULT_ARROW);
		setSmooth(DEFAULT_SMOOTH);
		setPoints(points);
	}
	
	public void setPoints(List<Point> newPoint) {
		if (points == newPoint)
			return;
		points = newPoint;
		arrowPolygons = null;
		notifyObservers(POINTS_UPDATED);
	}
		
	public List<Point> getPoints() {
		return points;
	}

	public void setColor(Color newColor) {
		if (color == newColor)
			return;
		if (color != null)
			color.removeObserver(this);
		color = newColor;
		if (newColor != null)
			newColor.addObserver(this);
		notifyObservers(COLOR_SWAPPED);
	}

	public Color getColor() {
		return color;
	}

	public void setLinePattern(Types.LinePattern newLinePattern) {
		if (linePattern == newLinePattern)
			return;
		linePattern = newLinePattern;
		notifyObservers(LINE_PATTERN_UPDATED);
	}

	public Types.LinePattern getLinePattern() {
		return linePattern;
	}
	public void setThickness(double newThickness) {
		if (thickness == newThickness)
			return;
		thickness = newThickness;
		notifyObservers(THICKNESS_UPDATE);
	}

	public double getThickness() {
		return thickness;
	}

	private void fixArrowPolygon() {
		if (points.size() >= 2) {
		arrowPolygons = new Polygon[2];
			for (int i = 0; i < 2; i++) {
				if (arrow[0] == Arrow.NONE) {
					arrowPolygons[i] = null;
				} else {
					int tip = i * (points.size() - 1);
					Point p1 = points.get(tip + 1 - (2 * i));
					Point p2 = points.get(tip);
					arrowPolygons[i] = createArrowPolygon(p1, p2);
					if (arrow[i] == Arrow.FILLED) 
						arrowPolygons[i].setFillPattern(FillPattern.SOLID);
				}
			}
		}
	}
	
	private Polygon createArrowPolygon(Point p1, Point p2) {
		double arrowSizePixles = arrowSize*IconConstants.PIXLES_PER_MM*2.0;
    	double x1 = p1.getX();
    	double y1 = p1.getY();
    	double x2 = p2.getX();
    	double y2 = p2.getY();

    	double vector1x = x2-x1;
    	double vector1y = y2-y1;
  
    	double vector1abs = Math.sqrt(vector1x*vector1x+vector1y*vector1y);
    	
    	double vector1normx = vector1x/vector1abs;
    	double vector1normy = vector1y/vector1abs;
    	
    	double vector2normx = -vector1normy;
    	double vector2normy = vector1normx;
    	
    	Point p3 = new Point(
    			x2-arrowSizePixles*vector1normx,
    			y2-arrowSizePixles*vector1normy
    	);
    	
    	Point p4 = new Point(
    			p3.getX()+0.5*arrowSizePixles*vector2normx, 
    			p3.getY()+0.5*arrowSizePixles*vector2normy
    	);

    	Point p5 = new Point(
    			p3.getX()-0.5*arrowSizePixles*vector2normx, 
    			p3.getY()-0.5*arrowSizePixles*vector2normy
    	);
    	
    	ArrayList<Point> arrowpoints = new ArrayList<Point>();

    	arrowpoints.add(p2);
    	arrowpoints.add(p4);
    	arrowpoints.add(p5);
    	
    	Polygon arrowPolygon = new Polygon(arrowpoints);    	
    	return arrowPolygon;
	}
	
	public Polygon[] getArrowPolygons() {
		if (arrowPolygons == null)
			fixArrowPolygon();
		return arrowPolygons;
	}
	
	public void setArrow(Types.Arrow[] newArrow) {
		if (arrow == newArrow)
			return;
		arrow = newArrow;
		arrowPolygons = null;
		notifyObservers(ARROW_UPDATED);
	}

	public Types.Arrow[] getArrow() {
		return arrow;
	}

	public void setArrowSize(double newArrowSize) {
		if (arrowSize == newArrowSize)
			return;
		arrowSize = newArrowSize;
		arrowPolygons = null;
		notifyObservers(ARROW_SIZE_UPDATED);
	}

	public double getArrowSize() {
		return arrowSize;
	}

	public void setSmooth(Types.Smooth newSmooth) {
		if (smooth == newSmooth)
			return;
		smooth = newSmooth;
		notifyObservers(SMOOTH_UPDATED);
	}

	public Types.Smooth getSmooth() {
		return smooth;
	}
	
	public Extent getBounds() {
		if (points == null || points.size() == 0) {
			return null;
		}
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
	
	public String toString() {
		String s = "";
		for (int i = 0; i < points.size(); i++) {
			s += "\nP" + i + " = " + points.get(i);
		}
		s += "\ncolor = " + color;
		return s+super.toString(); 
	}
	
	@Override
	public void update(Observable o, Object flag) {
		if (o == color && (flag == Color.RED_CHANGED || flag == Color.GREEN_CHANGED || flag == Color.BLUE_CHANGED))
			notifyObservers(COLOR_UPDATE);
		else
			super.update(o, flag);
	}
}