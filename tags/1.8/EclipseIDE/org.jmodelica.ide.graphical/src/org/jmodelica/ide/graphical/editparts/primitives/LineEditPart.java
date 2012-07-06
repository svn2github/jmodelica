package org.jmodelica.ide.graphical.editparts.primitives;


import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.Polyline;
import org.eclipse.draw2d.geometry.PointList;
import org.eclipse.swt.SWT;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.icons.primitives.Types.LinePattern;
import org.jmodelica.ide.graphical.util.Converter;
import org.jmodelica.ide.graphical.util.Transform;


public class LineEditPart extends GraphicEditPart {
	
	public LineEditPart(Line model) {
		super(model);
	}
	
	@Override
	public Line getModel() {
		return (Line) super.getModel();
	}
	
	@Override
	protected IFigure createFigure() {
		Polyline p = new Polyline();
//		p.setAntialias(SWT.ON);
		return p;
	}
	
	@Override
	public Polyline getFigure() {
		return (Polyline) super.getFigure();
	}
	
	@Override
	public void addNotify() {
		updateArrows();
		updateColor();
		updatePattern();
		updatePoints();
		updateSmooth();
		updateThickness();
		super.addNotify();
	}
	
	protected void setFigurePoints(PointList points) {
		getFigure().setPoints(points);
	}
	
	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getModel()) {
			if (flag == Line.ARROW_SIZE_UPDATED || flag == Line.ARROW_UPDATED)
				updateArrows();
			else if (flag == Line.COLOR_UPDATE)
				updateColor();
			else if (flag == Line.LINE_PATTERN_UPDATED)
				updatePattern();
			else if (flag == Line.POINTS_UPDATED)
				updatePoints();
			else if (flag == Line.SMOOTH_UPDATED)
				updateSmooth();
			else if (flag == Line.THICKNESS_UPDATE)
				updateThickness();
		}
		super.update(o, flag, additionalInfo);
	}
	
	
	private void updateArrows() {
		// TODO Implement arrows
	}

	protected void updateColor() {
		getFigure().setForegroundColor(Converter.convert(getModel().getColor()));
	}

	private void updatePattern() {
		if (getModel().getLinePattern() == LinePattern.NONE) {
			getFigure().setVisible(false);
		} else {
			getFigure().setVisible(true);
			if (getModel().getLinePattern() == LinePattern.SOLID) {
				getFigure().setLineStyle(SWT.LINE_SOLID);
			} else {
				getFigure().setLineStyle(SWT.LINE_CUSTOM);
				getFigure().setLineDash(getModel().getLinePattern().getDash());
			}
		}
	}

	private void updatePoints() {
		setFigurePoints(Converter.convert(getTransform().transform(Transform.yInverter.transform(getModel().getPoints()))));
	}

	private void updateSmooth() {
		// TODO Implement smoothnes
	}

	private void updateThickness() {
		getFigure().setLineWidthFloat((float) (getTransform().getScale() * getModel().getThickness()));
	}

	@Override
	protected void transformInvalid() {
		updatePoints();
	}

}
