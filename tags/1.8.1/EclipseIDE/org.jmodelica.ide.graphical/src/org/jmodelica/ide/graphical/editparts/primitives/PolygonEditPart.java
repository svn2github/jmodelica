package org.jmodelica.ide.graphical.editparts.primitives;

import java.util.List;

import org.jmodelica.icons.Observable;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.primitives.Polygon;

public class PolygonEditPart extends AbstractPolygonEditPart {
	
	public PolygonEditPart(Polygon model) {
		super(model);
	}

	@Override
	public Polygon getModel() {
		return (Polygon) super.getModel();
	}
	
	@Override
	protected List<Point> getPoints() {
		return getModel().getPoints();
	}
	
	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getModel()) {
			if (flag == Polygon.POINTS_CHANGED)
				updatePoints();
			else if (flag == Polygon.SMOOTH_CHANGED)
				updateSmooth();
		}
		super.update(o, flag, additionalInfo);
	}

	private void updateSmooth() {
		//TODO: Implement smoothing.
	}
}
