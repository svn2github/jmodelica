package org.jmodelica.icons.primitives;


import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.primitives.Types.FillPattern;
import org.jmodelica.icons.primitives.Types.LinePattern;

public abstract class FilledShape extends GraphicItem {
	
	public static final Object LINE_COLOR_UPDATED = new Object();
	public static final Object FILL_COLOR_UPDATED = new Object();
	public static final Object LINE_PATTERN_CHANGED = new Object();
	public static final Object FILL_PATTERN_CHANGED = new Object();
	public static final Object LINE_THICKNESS_CHANGED = new Object();
	
	public static final Color DEFAULT_LINE_COLOR = Color.BLACK;
	public static final Color DEFAULT_FILL_COLOR = Color.BLACK;
	public static final Types.LinePattern DEFAULT_LINE_PATTERN = Types.LinePattern.SOLID;
	public static final Types.FillPattern DEFAULT_FILL_PATTERN = Types.FillPattern.NONE;
	public static final double DEFAULT_LINE_THICKNESS = 0.25;
	public static final double PATTERN_LINE_DISTANCE = 15.0;
	
	protected Color lineColor;
	protected Color fillColor;
	protected Types.LinePattern linePattern;
	protected Types.FillPattern fillPattern;
	protected double lineThickness;
	
	
	public FilledShape(boolean visible, Point origin, double rotation, 
			Color lineColor, Color fillColor, Types.LinePattern linePattern,
			Types.FillPattern fillPattern, double lineThickness) {
		super(visible, origin, rotation);
		setLineColor(lineColor);
		setFillColor(fillColor);
		setLinePattern(linePattern);
		setFillPattern(fillPattern);
		setLineThickness(lineThickness);
	}
	
	public FilledShape(Color lineColor, Color fillColor, Types.LinePattern linePattern,
			Types.FillPattern fillPattern, double lineThickness) {
		super();
		setLineColor(lineColor);
		setFillColor(fillColor);
		setLinePattern(linePattern);
		setFillPattern(fillPattern);
		setLineThickness(lineThickness);
	}

	
	public FilledShape() {
		this(DEFAULT_LINE_COLOR, DEFAULT_FILL_COLOR, DEFAULT_LINE_PATTERN, DEFAULT_FILL_PATTERN, DEFAULT_LINE_THICKNESS);
	}
	
	public FillPattern getFillPattern() {
		return fillPattern;
	}
	
	public void setFillPattern(Types.FillPattern newFillPattern) {
		if (fillPattern == newFillPattern)
			return;
		fillPattern = newFillPattern;
		notifyObservers(FILL_PATTERN_CHANGED);
	}
	public void setLinePattern(Types.LinePattern newLinePattern) {
		if (linePattern == newLinePattern)
			return;
		linePattern = newLinePattern;
		notifyObservers(LINE_PATTERN_CHANGED);
	}
	public LinePattern getLinePattern() {
		return linePattern;
	}
	public void setFillColor(Color newFillColor) {
		if (fillColor == newFillColor)
			return;
		fillColor = newFillColor;
		notifyObservers(FILL_COLOR_UPDATED);
	}
	
	public Color getFillColor() {
		return fillColor;
	}
	public void setLineColor(Color newLineColor) {
		if (lineColor == newLineColor)
			return;
		lineColor = newLineColor;
		notifyObservers(LINE_COLOR_UPDATED);
	}
	public Color getLineColor() {
		return lineColor;
	}
	public void setLineThickness(double newLineThickness) {
		if (lineThickness == newLineThickness)
			return;
		lineThickness = newLineThickness;
		notifyObservers(LINE_THICKNESS_CHANGED);
	}
	public double getLineThickness() {
		return lineThickness;
	}
	
	public String toString() {
		String s = "";
		s += "lineColor = " + lineColor;
		s += "\nfillColor = " + fillColor;
		s += "\nlinePattern = " + linePattern;
		s += "\nfillPattern = " + fillPattern;
		return s+super.toString();
	}
	
}