package org.jmodelica.ide.graphical.edit.parts;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.draw2d.ConnectionLayer;
import org.eclipse.draw2d.FreeformLayer;
import org.eclipse.draw2d.FreeformLayout;
import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.MarginBorder;
import org.eclipse.draw2d.geometry.Dimension;
import org.eclipse.gef.CompoundSnapToHelper;
import org.eclipse.gef.EditPolicy;
import org.eclipse.gef.LayerConstants;
import org.eclipse.gef.SnapToGeometry;
import org.eclipse.gef.SnapToGrid;
import org.eclipse.gef.SnapToHelper;
import org.eclipse.gef.editpolicies.SnapFeedbackPolicy;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.ide.graphical.edit.DiagramConnectionRouter;
import org.jmodelica.ide.graphical.edit.MySnapToGrid;
import org.jmodelica.ide.graphical.edit.policies.DiagramPolicy;
import org.jmodelica.ide.graphical.proxy.AbstractDiagramProxy;
import org.jmodelica.ide.graphical.proxy.ClassDiagramProxy;
import org.jmodelica.ide.graphical.util.Converter;
import org.jmodelica.ide.graphical.util.Transform;

public class DiagramPart extends AbstractInstNodePart {

	public DiagramPart(AbstractDiagramProxy model) {
		super(model);
	}

	@Override
	public AbstractDiagramProxy getModel() {
		return (AbstractDiagramProxy) super.getModel();
	}

	@Override
	protected IFigure createFigure() {
		IFigure f = new FreeformLayer();
		f.setBorder(new MarginBorder(3));
		f.setLayoutManager(new FreeformLayout());

		// Create the static router for the connection layer
		ConnectionLayer connLayer = (ConnectionLayer) getLayer(LayerConstants.CONNECTION_LAYER);
		connLayer.setConnectionRouter(new DiagramConnectionRouter());

		return f;
	}
	
	@Override
	public void addNotify() {
		super.addNotify();
		updateGrid();
	}

	@Override
	protected Transform calculateTransform() {
		Transform transform = new Transform();
		transform.translate(300, 300);
		transform.scale(4);
		return transform;
	}

	@Override
	protected void createEditPolicies() {
		installEditPolicy("Snap Feedback", new SnapFeedbackPolicy());
		installEditPolicy(EditPolicy.LAYOUT_ROLE, new DiagramPolicy(this));
	}

	@Override
	public Object getAdapter(@SuppressWarnings("rawtypes") Class key) {
		if (key == SnapToHelper.class) {
			List<SnapToHelper> helpers = new ArrayList<SnapToHelper>();
			if (Boolean.TRUE.equals(getViewer().getProperty(SnapToGeometry.PROPERTY_SNAP_ENABLED)))
				helpers.add(new SnapToGeometry(this));
			if (Boolean.TRUE.equals(getViewer().getProperty(SnapToGrid.PROPERTY_GRID_ENABLED)))
				helpers.add(new MySnapToGrid(this));

			if (helpers.size() == 0)
				return null;

			return new CompoundSnapToHelper(helpers.toArray(new SnapToHelper[helpers.size()]));
		}
		return super.getAdapter(key);
	}
	
	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getModel() && flag == ClassDiagramProxy.COMPONENT_ADDED)
			refreshChildren();
		if (o == getModel() && flag == ClassDiagramProxy.COMPONENT_REMOVED)
			refreshChildren();
		super.update(o, flag, additionalInfo);
	}

	@Override
	protected void updateGrid() {
		Transform transform = getTransform();
		double[] realGrid = getModel().getLayer().getCoordinateSystem().getGrid();
		Point grid = transform.transform(new Point(realGrid[0], realGrid[0]));
		Point origin = transform.transform(new Point(0, 0));

		getViewer().setProperty(SnapToGrid.PROPERTY_GRID_ORIGIN, Converter.convert(origin));
		getViewer().setProperty(SnapToGrid.PROPERTY_GRID_SPACING, new Dimension((int) Math.abs(grid.getX() - origin.getX()), (int) Math.abs(grid.getY() - origin.getY())));
	}
}
