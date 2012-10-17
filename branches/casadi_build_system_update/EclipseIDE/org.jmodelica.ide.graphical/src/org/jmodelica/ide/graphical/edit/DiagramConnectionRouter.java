package org.jmodelica.ide.graphical.edit;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.draw2d.AbsoluteBendpoint;
import org.eclipse.draw2d.Bendpoint;
import org.eclipse.draw2d.ChopboxAnchor;
import org.eclipse.draw2d.Connection;
import org.eclipse.draw2d.ConnectionRouter;
import org.eclipse.draw2d.PositionConstants;
import org.eclipse.draw2d.XYAnchor;
import org.eclipse.draw2d.geometry.Point;
import org.eclipse.draw2d.geometry.PointList;
import org.jmodelica.ide.graphical.graphics.ConnectionFigure;
import org.jmodelica.ide.graphical.graphics.TemporaryConnectionFigure;

public class DiagramConnectionRouter implements ConnectionRouter {

	@Override
	public List<Bendpoint> getConstraint(Connection connection) {
		if (connection instanceof ConnectionFigure) {
			PointList constraint = ((ConnectionFigure) connection).getPoints();
			ArrayList<Bendpoint> list = new ArrayList<Bendpoint>();
			for (int i = 1; i < constraint.size() - 1; i++)
				list.add(new AbsoluteBendpoint(constraint.getPoint(i)));
			return list;
		}
		return null;
	}

	@Override
	public void invalidate(Connection connection) {}

	@Override
	public void route(Connection connection) {
		PointList constraint;
		if (connection instanceof ConnectionFigure) {
			constraint = ((ConnectionFigure) connection).getRealPoints();
		} else if (connection instanceof TemporaryConnectionFigure) {
			constraint = new PointList();
			TemporaryConnectionFigure tcf = (TemporaryConnectionFigure) connection;

			int srcDir = tcf.getSourceDirection();
			int tarDir = tcf.getTargetDirection();

			if (srcDir != PositionConstants.NONE) {
				// Escape it from the icon
			}

			if (tarDir != PositionConstants.NONE) {
				// Escape it from the icon
			}

			// do something cleaver here
		} else {
			constraint = new PointList();
		}

		PointList points = constraint.getCopy();
		if (points.size() == 0) {
			Point p = connection.getSourceAnchor().getReferencePoint();
			if (connection.getSourceAnchor() instanceof ChopboxAnchor) {
				connection.translateToRelative(p);
			}
			points.addPoint(p);
			p = connection.getTargetAnchor().getReferencePoint();
			if (connection.getTargetAnchor() instanceof ChopboxAnchor) {
				connection.translateToRelative(p);
			}
			points.addPoint(p);
		}

		if (connection.getSourceAnchor() instanceof ChopboxAnchor && connection.getSourceAnchor().getOwner() != null && !connection.getSourceAnchor().getOwner().containsPoint(points.getFirstPoint())) {
			points.setPoint(connection.getSourceAnchor().getReferencePoint(), 0);
		}

		if (connection.getTargetAnchor() instanceof ChopboxAnchor && connection.getTargetAnchor().getOwner() != null && !connection.getTargetAnchor().getOwner().containsPoint(points.getLastPoint())) {
			points.setPoint(connection.getSourceAnchor().getReferencePoint(), points.size() - 1);
		}

		Point ref = points.getPoint(1);

		if (!(points.size() == 2 && connection.getTargetAnchor() instanceof XYAnchor))
			connection.translateToAbsolute(ref);
		Point p = connection.getSourceAnchor().getLocation(ref);
		connection.translateToRelative(p);
		points.setPoint(p, 0);

		ref = points.getPoint(points.size() - 2);

		if (!(points.size() == 2 && connection.getSourceAnchor() instanceof XYAnchor))
			connection.translateToAbsolute(ref);
		p = connection.getTargetAnchor().getLocation(ref);
		connection.translateToRelative(p);
		points.setPoint(p, points.size() - 1);

		connection.setPoints(points);
	}

	@Override
	public void remove(Connection connection) {}

	@Override
	public void setConstraint(Connection connection, Object constraint) {
		@SuppressWarnings("unchecked")
		List<Bendpoint> bendpoints = (List<Bendpoint>) constraint;
		PointList newPoints = new PointList(bendpoints.size() + 2);
		newPoints.addPoint(connection.getSourceAnchor().getReferencePoint());
		for (Bendpoint point : bendpoints)
			newPoints.addPoint(point.getLocation());
		newPoints.addPoint(connection.getTargetAnchor().getReferencePoint());
		((ConnectionFigure) connection).setRealPoints(newPoints);
	}

}
