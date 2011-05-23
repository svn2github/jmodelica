package org.jmodelica.icons.mls;


import org.jmodelica.icons.mls.Color;
import org.jmodelica.icons.mls.Types.FillPattern;
import org.jmodelica.icons.mls.Types.LinePattern;

public abstract class FilledShape extends GraphicItem {
	
	protected Color lineColor;
	protected Color fillColor;
	protected Types.LinePattern linePattern;
	protected Types.FillPattern fillPattern;
	protected double lineThickness;
	
	
	protected static final Color DEFAULT_LINE_COLOR = Color.BLACK;
	protected static final Color DEFAULT_FILL_COLOR = Color.BLACK;
	protected static final Types.LinePattern DEFAULT_LINE_PATTERN = Types.LinePattern.SOLID;
	protected static final Types.FillPattern DEFAULT_FILL_PATTERN = Types.FillPattern.NONE;
	public static final double DEFAULT_LINE_THICKNESS = 0.25;
	protected static final double PATTERN_LINE_DISTANCE = 15.0;
	
	public FilledShape(boolean visible, Point origin, double rotation, 
			Color lineColor, Color fillColor, Types.LinePattern linePattern,
			Types.FillPattern fillPattern, double lineThickness) {
		super(visible, origin, rotation);
		this.lineColor = lineColor;
		this.fillColor = fillColor;
		this.linePattern = linePattern;
		this.fillPattern = fillPattern;
		this.lineThickness = lineThickness;
	}
	
	public FilledShape(Color lineColor, Color fillColor, Types.LinePattern linePattern,
			Types.FillPattern fillPattern, double lineThickness) {
		super();
		this.lineColor = lineColor;
		this.fillColor = fillColor;
		this.linePattern = linePattern;
		this.fillPattern = fillPattern;
		this.lineThickness = lineThickness;
	}

	
	public FilledShape() {
		this(DEFAULT_LINE_COLOR, DEFAULT_FILL_COLOR, DEFAULT_LINE_PATTERN,
				DEFAULT_FILL_PATTERN, DEFAULT_LINE_THICKNESS);
	}
	
	public FillPattern getFillPattern() {
		return fillPattern;
	}
	
	public void setFillPattern(Types.FillPattern pattern) {
		this.fillPattern = pattern;
	}
	public void setLinePattern(Types.LinePattern pattern) {
		this.linePattern = pattern;
	}
	public LinePattern getLinePattern() {
		return linePattern;
	}
	public void setFillColor(Color color) {
		this.fillColor = color;
	}
	
	public Color getFillColor() {
		return fillColor;
	}
	public void setLineColor(Color color) {
		this.lineColor = color;
	}
	public Color getLineColor() {
		return lineColor;
	}
	public void setLineThickness(double mm) {
		this.lineThickness = mm;
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