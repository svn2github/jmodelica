package org.jmodelica.ide.graphical.graphics;

import org.eclipse.draw2d.ColorConstants;
import org.eclipse.draw2d.Cursors;
import org.eclipse.draw2d.Graphics;
import org.eclipse.draw2d.geometry.PointList;
import org.eclipse.gef.DragTracker;
import org.eclipse.gef.EditPart;
import org.eclipse.gef.handles.AbstractHandle;
import org.eclipse.gef.tools.ResizeTracker;
import org.eclipse.swt.SWT;
import org.jmodelica.ide.graphical.editparts.ComponentEditPart;


public class RotatableHandle extends AbstractHandle {
	
	private PointList points;
	
	public RotatableHandle(ComponentEditPart owner, RotatableLocator locator) {
		super(owner, locator);
	}

	@Override
	protected DragTracker createDragTracker() {
		return new ResizeTracker(getOwner(), getLocator().getDirection(getOwner().getTransform()));
	}
	
	@Override
	protected void paintFigure(Graphics graphics) {
		graphics.setAntialias(SWT.ON);
		graphics.setBackgroundColor(isPrimary() ? ColorConstants.black : ColorConstants.white);
		graphics.fillPolygon(points);
		graphics.setForegroundColor(isPrimary() ? ColorConstants.white : ColorConstants.black);
		graphics.drawPolygon(points);
	}
	
	public void setPoints(PointList points) {
		this.points = points;
	}
	
	@Override
	protected ComponentEditPart getOwner() {
		return (ComponentEditPart) super.getOwner();
	}
	
	@Override
	public RotatableLocator getLocator() {
		return (RotatableLocator) super.getLocator();
	}
	
	protected boolean isPrimary() {
		return getOwner().getSelected() == EditPart.SELECTED_PRIMARY;
	}
	
	@Override
	public void validate() {
		setCursor(Cursors.getDirectionalCursor(getLocator().getDirection(getOwner().getTransform())));
		super.validate();
	}
	
}
