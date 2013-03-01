package org.jmodelica.ide.graphical.edit;

import org.eclipse.draw2d.geometry.Dimension;
import org.eclipse.draw2d.geometry.Point;
import org.eclipse.draw2d.geometry.PrecisionRectangle;
import org.eclipse.draw2d.geometry.Rectangle;
import org.eclipse.gef.EditPart;
import org.eclipse.gef.GraphicalEditPart;
import org.eclipse.gef.Request;
import org.eclipse.gef.SnapToGrid;
import org.eclipse.gef.requests.ChangeBoundsRequest;
import org.eclipse.gef.requests.GroupRequest;
import org.jmodelica.ide.graphical.edit.parts.ComponentPart;

public class MySnapToGrid extends SnapToGrid {

	public static final double RESIZE_THRESHOLD = 7;
	public static final double MOVE_THRESHOLD = Double.MAX_VALUE;

	public MySnapToGrid(GraphicalEditPart container) {
		super(container);
	}

	/**
	 * Based on org.eclipse.gef.SnapToGrid.snapRectangle()
	 */
	@Override
	public int snapRectangle(Request request, int snapLocations, PrecisionRectangle rect, PrecisionRectangle result) {
		boolean isResize = false;

		if (request instanceof ChangeBoundsRequest) {
			EditPart part = (EditPart) ((GroupRequest) request).getEditParts().get(0);
			if (part instanceof ComponentPart) {
				ComponentPart component = (ComponentPart) part;
				Rectangle r = component.getFigure().getHandleBounds();
				Dimension sizeDelta = ((ChangeBoundsRequest) request).getSizeDelta();
				Point moveDelta = ((ChangeBoundsRequest) request).getMoveDelta();
				rect = new PrecisionRectangle(r.getCopy().translate(moveDelta).resize(sizeDelta));
			} else {
				return snapLocations;
			}
		} else {
			return snapLocations;
		}

		makeRelative(container.getContentPane(), rect);
		PrecisionRectangle correction = new PrecisionRectangle();
		makeRelative(container.getContentPane(), correction);

		if (gridX > 0 && (snapLocations & EAST) != 0) {
			isResize = true;
			correction.setPreciseWidth(correction.preciseWidth() - Math.IEEEremainder(rect.preciseRight() - origin.x - 1, gridX));
			snapLocations &= ~EAST;
		}

		if (gridX > 0 && (snapLocations & WEST) != 0) {
			isResize = true;
			double leftCorrection = Math.IEEEremainder(rect.preciseX() - origin.x - 1, gridX);
			correction.setPreciseX(correction.preciseX() - leftCorrection);
			correction.setPreciseWidth(correction.preciseWidth() + leftCorrection);
			snapLocations &= ~WEST;
		}

		if (gridX > 0 && (snapLocations & HORIZONTAL) != 0) {
			correction.setPreciseX(correction.preciseX() - Math.IEEEremainder(rect.getCenter().x - origin.x, gridX));
			snapLocations &= ~HORIZONTAL;
		}

		if ((snapLocations & SOUTH) != 0 && gridY > 0) {
			isResize = true;
			correction.setPreciseHeight(correction.preciseHeight() - Math.IEEEremainder(rect.preciseBottom() - origin.y - 1, gridY));
			snapLocations &= ~SOUTH;
		}

		if (gridX > 0 && (snapLocations & NORTH) != 0) {
			isResize = true;
			double topCorrection = Math.IEEEremainder(rect.preciseY() - origin.y - 1, gridY);
			correction.setPreciseY(correction.preciseY() - topCorrection);
			correction.setPreciseHeight(correction.preciseHeight() + topCorrection);
			snapLocations &= ~NORTH;
		}

		if (gridX > 0 && (snapLocations & VERTICAL) != 0) {
			correction.setPreciseY(correction.preciseY() - Math.IEEEremainder(rect.getCenter().y - origin.y, gridY));
			snapLocations &= ~VERTICAL;
		}

		double threshold;
		if (isResize)
			threshold = RESIZE_THRESHOLD;
		else
			threshold = MOVE_THRESHOLD;

		makeAbsolute(container.getContentPane(), rect);
		makeAbsolute(container.getContentPane(), correction);

		if (Math.abs(correction.preciseX()) > threshold || Math.abs(correction.preciseWidth()) > threshold) {
			correction.setPreciseWidth(0);
			correction.setPreciseX(0);
		}
		if (Math.abs(correction.preciseY()) > threshold || Math.abs(correction.preciseHeight()) > threshold) {
			correction.setPreciseHeight(0);
			correction.setPreciseY(0);
		}

		result.setPreciseX(result.preciseX() + correction.preciseX());
		result.setPreciseY(result.preciseY() + correction.preciseY());
		result.setPreciseWidth(result.preciseWidth() + correction.preciseWidth());
		result.setPreciseHeight(result.preciseHeight() + correction.preciseHeight());
		return snapLocations;
	}
}
