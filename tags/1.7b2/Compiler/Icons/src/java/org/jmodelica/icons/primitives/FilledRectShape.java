package org.jmodelica.icons.primitives;

import org.jmodelica.icons.coord.Extent;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.primitives.Color;
import org.jmodelica.icons.primitives.Types.FillPattern;
import org.jmodelica.icons.primitives.Types.LinePattern;


public abstract class FilledRectShape extends FilledShape {
	
	protected Extent extent;
	
	public FilledRectShape(Extent extent, boolean visible, Point origin, 
			double rotation, Color lineColor, Color fillColor, 
			LinePattern pattern, FillPattern fillPattern, double lineThickness) {
		super(visible, origin, rotation, lineColor, fillColor, pattern, fillPattern,
				lineThickness);
		this.extent = extent.fix();
	}
	
	public FilledRectShape(Extent extent) {
		super();
		this.extent = extent.fix();
	}
	
	public FilledRectShape() {
		super();
		extent = Extent.NO_EXTENT;
	}
	
	public void setExtent(Extent extent) {
		this.extent = extent.fix();
	}

	public Extent getExtent() {
		return extent;
	}
	
	public Extent getBounds() {
		return extent;
	}
	
	public String toString() {
		return "extent = " + extent.toString() + super.toString();
	}
}