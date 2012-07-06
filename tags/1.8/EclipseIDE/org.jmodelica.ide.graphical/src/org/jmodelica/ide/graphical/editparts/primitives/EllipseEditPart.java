package org.jmodelica.ide.graphical.editparts.primitives;

import java.util.ArrayList;
import java.util.List;

import org.jmodelica.icons.Observable;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.primitives.Ellipse;

public class EllipseEditPart extends AbstractPolygonEditPart {
	
	public EllipseEditPart(Ellipse model) {
		super(model);
	}
	
	@Override
	public Ellipse getModel() {
		return (Ellipse) super.getModel();
	}
	
	@Override
	protected List<Point> getPoints() {
		ArrayList<Point> points = new ArrayList<Point>();
		
		double startAngle = getModel().getStartAngle() * Math.PI / 180;
		double endAngle = getModel().getEndAngle() * Math.PI / 180;
		
		if (startAngle >= endAngle)
			return points;
		
		Point middle = getModel().getExtent().getMiddle();
		
		if (endAngle - startAngle < Math.PI * 2 - 0.00000001)
			points.add(middle);
		
		double angleIncrement = Math.PI * 2 / 24;
		double angle = startAngle - angleIncrement;
		double width = getModel().getExtent().getWidth() / 2;
		double height = getModel().getExtent().getHeight() / 2;
		do {
			angle += angleIncrement;
			if (angle > endAngle) {
				angle = endAngle;
			}
			points.add(new Point(width * Math.cos(angle) + middle.getX(), height * Math.sin(angle) + middle.getY()));
		} while (angle < endAngle);
		
		return points;
	}
	
	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getModel()) {
			if (flag == Ellipse.END_ANGLE_CHANGED)
				updateEndAngle();
			if (flag == Ellipse.START_ANGLE_CHANGED)
				updateStartAngle();
		}
		super.update(o, flag, additionalInfo);
	}

	private void updateEndAngle() {
		updatePoints();
	}

	private void updateStartAngle() {
		updatePoints();
	}
	
}
