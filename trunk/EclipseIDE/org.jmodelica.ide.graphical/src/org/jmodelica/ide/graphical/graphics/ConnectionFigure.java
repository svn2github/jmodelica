package org.jmodelica.ide.graphical.graphics;

import org.eclipse.draw2d.PolylineConnection;
import org.eclipse.draw2d.geometry.PointList;

public class ConnectionFigure extends PolylineConnection {

	public static final String REAL_POINTS_CHANGED = "RealPointsChanged";

	private PointList realPoints;

	public void setRealPoints(PointList points) {
		PointList old = realPoints;
		realPoints = points;
		firePropertyChange(REAL_POINTS_CHANGED, old, points);
	}

	public PointList getRealPoints() {
		return realPoints;
	}

}
