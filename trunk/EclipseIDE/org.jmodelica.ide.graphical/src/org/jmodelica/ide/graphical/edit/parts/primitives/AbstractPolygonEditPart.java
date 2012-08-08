package org.jmodelica.ide.graphical.edit.parts.primitives;

import java.util.List;


import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.Polygon;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.primitives.Color;
import org.jmodelica.icons.primitives.FilledShape;
import org.jmodelica.ide.graphical.util.Converter;
import org.jmodelica.ide.graphical.util.Transform;

public abstract class AbstractPolygonEditPart extends GraphicEditPart {

	public AbstractPolygonEditPart(FilledShape model) {
		super(model);
	}

	@Override
	public FilledShape getModel() {
		return (FilledShape)super.getModel();
	}
	
	@Override
	protected IFigure createFigure() {
		Polygon p = new Polygon();
		p.setFill(true);
//		p.setAntialias(SWT.ON);
		return p;
	}

	@Override
	public Polygon getFigure() {
		return (Polygon) super.getFigure();
	}
	
	@Override
	public void addNotify() {
		updateFillColor();
		updateFillpattern();
		updateLineColor();
		updateLinePattern();
		updateLineThickness();
		updatePoints();
		super.addNotify();
	}
	
	@Override
	protected void transformInvalid() {
		updatePoints();
	}
	
	@Override
	public Color calculateConnectionColor() {
		return getModel().getLineColor();
	}
	
	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getModel()) {
			if (flag == FilledShape.FILL_COLOR_UPDATED)
				updateFillColor();
			else if (flag == FilledShape.FILL_PATTERN_CHANGED)
				updateFillpattern();
			else if (flag == FilledShape.LINE_COLOR_UPDATED)
				updateLineColor();
			else if (flag == FilledShape.LINE_PATTERN_CHANGED)
				updateLinePattern();
			else if (flag == FilledShape.LINE_THICKNESS_CHANGED)
				updateLineThickness();
		}
		super.update(o, flag, additionalInfo);
	}
	
	private void updateFillColor() {
		getFigure().setBackgroundColor(Converter.convert(getModel().getFillColor()));
	}
	
	private void updateFillpattern() {
		// TODO: implement fill patterns.
	}

	private void updateLineColor() {
		getFigure().setForegroundColor(Converter.convert(getModel().getLineColor()));
	}

	private void updateLinePattern() {
		getFigure().setLineDash(getModel().getLinePattern().getDash());
	}

	private void updateLineThickness() {
		getFigure().setLineWidthFloat((float) (getTransform().getScale() * getModel().getLineThickness()));
	}
	
	protected abstract List<Point> getPoints();
	
	protected void updatePoints() {
		getFigure().setPoints(Converter.convert(getTransform().transform(Transform.yInverter.transform(getPoints()))));
	}

}