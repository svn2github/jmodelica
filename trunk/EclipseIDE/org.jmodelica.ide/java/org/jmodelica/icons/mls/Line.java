package org.jmodelica.icons.mls;

import java.util.ArrayList;

import org.jmodelica.icons.mls.Color;
import org.jmodelica.icons.mls.Types.Arrow;
import org.jmodelica.icons.mls.Types.FillPattern;
import org.jmodelica.icons.IconConstants;

/* TODO fixa så att punkter hamnar rätt i kordinatsystemet */

public class Line extends GraphicItem {
	
	
	private ArrayList<Point> points;
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
	public static final Polygon[] DEFAULT_ARROW_POLYGONS = new Polygon[0];

	public Line() {
		super();
		color = DEFAULT_COLOR;
		linePattern = DEFAULT_LINE_PATTERN;
		thickness = DEFAULT_THICKNESS;
		arrowSize = DEFAULT_ARROW_SIZE;
		arrow = DEFAULT_ARROW;
		smooth = DEFAULT_SMOOTH;
		points = new ArrayList<Point>();
		arrowPolygons = new Polygon[0];
		
	}	
	public Line(ArrayList<Point> points) {
		super();
		this.points = points;
		color = DEFAULT_COLOR;
		linePattern = DEFAULT_LINE_PATTERN;
		thickness = DEFAULT_THICKNESS;
		arrowSize = DEFAULT_ARROW_SIZE;
		arrow = DEFAULT_ARROW;
		smooth = DEFAULT_SMOOTH;
		arrowPolygons = new Polygon[0];		
	}
	
	public void setPoints(ArrayList<Point> point) {
		this.points = point;
	}
		
	public ArrayList<Point> getPoints() {
		return points;
	}

	public void setColor(Color color) {
		this.color = color;
	}

	public Color getColor() {
		return color;
	}

	public void setLinePattern(Types.LinePattern linePattern) {
		this.linePattern = linePattern;
	}

	public Types.LinePattern getLinePattern() {
		return linePattern;
	}
	public void setThickness(double thickness) {
		this.thickness = thickness;
	}

	public double getThickness() {
		return thickness;
	}

	private void fixArrowPolygon() {
		arrowPolygons = new Polygon[2];
		
		if (arrow[0] != Arrow.NONE) {
		
			Point p1 = points.get(1);
			Point p2 = points.get(0);
			arrowPolygons[0] = createArrowPolygon(p1, p2);
			if (arrow[0] == Arrow.FILLED) {
				arrowPolygons[0].setFillPattern(FillPattern.SOLID);
			}
		} else {
			arrowPolygons[0] = null;
		}
		if (arrow[1] != Arrow.NONE) {
		
			Point p1 = points.get(points.size()-2);
			Point p2 = points.get(points.size()-1);
			arrowPolygons[1] = createArrowPolygon(p1, p2);
			if (arrow[1] == Arrow.FILLED) {
				arrowPolygons[1].setFillPattern(FillPattern.SOLID);
			}
		} else {
			arrowPolygons[1] = null;
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
		return arrowPolygons;
	}
	
	public void setArrow(Types.Arrow[] arrow) {
		this.arrow = arrow;
		if (arrow[0] != Arrow.NONE || arrow[1] != Arrow.NONE) {
			fixArrowPolygon();
		}
	}

	public Types.Arrow[] getArrow() {
		return arrow;
	}

	public void setArrowSize(double arrowSize) {
		this.arrowSize = arrowSize;
	}

	public double getArrowSize() {
		return arrowSize;
	}

	public void setSmooth(Types.Smooth smooth) {
		this.smooth = smooth;
	}

	public Types.Smooth getSmooth() {
		return smooth;
	}
	
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
	
	public String toString() {
		String s = "";
		for (int i = 0; i < points.size(); i++) {
			s += "\nP" + i + " = " + points.get(i);
		}
		s += "\ncolor = " + color;
		return s+super.toString(); 
	}
}