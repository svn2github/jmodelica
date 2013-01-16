package org.jmodelica.ide.graphical.edit.parts.primitives;

import java.util.Arrays;
import java.util.List;

import org.jmodelica.icons.Observable;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.primitives.Rectangle;

public class RectangleEditPart extends AbstractPolygonEditPart {
	
	public RectangleEditPart(Rectangle model) {
		super(model);
	}

	@Override
	public Rectangle getModel() {
		return (Rectangle) super.getModel();
	}
	
	@Override
	public void addNotify() {
		updateBorderPattern();
		updateRadius();
		super.addNotify();
	}
	
	@Override
	public void activate() {
		super.activate();
	}
	
	@Override
	protected List<Point> getPoints() {
		Point p1 = getModel().getExtent().getP1();
		Point p2 = getModel().getExtent().getP2();
		return Arrays.asList(new Point(p1.getX(), p1.getY()), new Point(p2.getX(), p1.getY()), new Point(p2.getX(), p2.getY()), new Point(p1.getX(), p2.getY()), new Point(p1.getX(), p1.getY()));
	}

	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getModel()) {
			if (flag == Rectangle.BORDER_PATTERN_CHANGED)
				updateBorderPattern();
			else if (flag == Rectangle.RADIUS_CHANGED)
				updateRadius();
		}
		super.update(o, flag, additionalInfo);
	}

	private void updateBorderPattern() {
		// TODO: implement border pattern.
	}

	private void updateRadius() {
		// TODO: implement radius
	}

}
