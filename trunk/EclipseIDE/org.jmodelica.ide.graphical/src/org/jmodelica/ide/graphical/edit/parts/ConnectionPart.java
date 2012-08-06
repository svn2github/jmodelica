package org.jmodelica.ide.graphical.edit.parts;

import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.util.Map;

import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.XYAnchor;
import org.eclipse.draw2d.geometry.Point;
import org.eclipse.draw2d.geometry.PointList;
import org.eclipse.gef.ConnectionEditPart;
import org.eclipse.gef.EditPart;
import org.eclipse.gef.EditPolicy;
import org.eclipse.gef.LayerConstants;
import org.jmodelica.ide.graphical.edit.parts.primitives.LineEditPart;
import org.jmodelica.ide.graphical.edit.policies.ConnectionBendpointPolicy;
import org.jmodelica.ide.graphical.edit.policies.ConnectionPolicy;
import org.jmodelica.ide.graphical.graphics.ConnectionFigure;
import org.jmodelica.ide.graphical.proxy.ConnectionProxy;
import org.jmodelica.ide.graphical.util.Converter;
import org.jmodelica.ide.graphical.util.Transform;

public class ConnectionPart extends LineEditPart implements ConnectionEditPart, PropertyChangeListener {

	private ConnectorPart sourcePart;
	private ConnectorPart targetPart;
	private boolean updatingFigurePoints = false;
	private ConnectionProxy connection;

	public ConnectionPart(ConnectionProxy connection) {
		super(connection.getLine());
		this.connection = connection;
	}

	@Override
	protected IFigure createFigure() {
		ConnectionFigure cf = new ConnectionFigure();
		cf.addPropertyChangeListener(ConnectionFigure.REAL_POINTS_CHANGED, this);
		return cf;
	}
	
	@SuppressWarnings("unchecked")
	@Override
	protected void registerModel() {
		getViewer().getEditPartRegistry().put(connection, this);
	}
	
	@SuppressWarnings("rawtypes")
	@Override
	protected void unregisterModel() {
		Map registry = getViewer().getEditPartRegistry();
		if (registry.get(connection) == this)
			registry.remove(connection);
	}

	@Override
	public ConnectionFigure getFigure() {
		return (ConnectionFigure) super.getFigure();
	}
	
	@Override
	protected void setFigurePoints(PointList points) {
		updatingFigurePoints  = true;
		getFigure().setRealPoints(points);
		refresh();
		updatingFigurePoints = false;
	}
	
	public ConnectionProxy getConnection() {
		return connection;
	}
	
	@Override
	public void setParent(EditPart parent) {
		while (parent != null && !(parent instanceof DiagramPart)) {
			parent = parent.getParent();
		}
		boolean wasNull = getParent() == null;
		boolean becomingNull = parent == null;
		if (becomingNull && !wasNull)
			removeNotify();
		super.setParent(parent);
		if (wasNull && !becomingNull)
			addNotify();
	}

	@Override
	public void refresh() {
		refreshAnchors();
		super.refresh();
		getFigure().layout();
	}

	private void refreshAnchors() {
		if (getSource() == null)
			getFigure().setSourceAnchor(new XYAnchor(new Point(10, 10)));
		else
			getFigure().setSourceAnchor(getSource().getSourceConnectionAnchor(this));

		if (getTarget() == null)
			getFigure().setTargetAnchor(new XYAnchor(new Point(100, 100)));
		else
			getFigure().setTargetAnchor(getTarget().getTargetConnectionAnchor(this));
	}

	@Override
	public void addNotify() {
		getLayer(LayerConstants.CONNECTION_LAYER).add(getFigure());
		super.addNotify();
	}

	@Override
	public void removeNotify() {
		getLayer(LayerConstants.CONNECTION_LAYER).remove(getFigure());
		getFigure().setSourceAnchor(null);
		getFigure().setTargetAnchor(null);
		super.removeNotify();
	}

	@Override
	public ConnectorPart getSource() {
		return sourcePart;
	}

	@Override
	public void setSource(EditPart source) {
		if (source == sourcePart)
			return;
		if (!(source instanceof ConnectorPart))
			source = null;
		sourcePart = (ConnectorPart) source;
		if (sourcePart != null) {
			setParent(sourcePart);
		} else if (getTarget() == null) {
			setParent(null);
		}
		if (sourcePart != null && getTarget() != null)
			refresh();
	}

	@Override
	public ConnectorPart getTarget() {
		return targetPart;
	}

	@Override
	public void setTarget(EditPart target) {
		if (target == targetPart)
			return;
		if (!(target instanceof ConnectorPart))
			target = null;
		targetPart = (ConnectorPart) target;
		if (targetPart != null) {
			setParent(targetPart);
		} else if (getSource() == null) {
			setParent(null);
		}
		if (targetPart != null && getSource() != null)
			refresh();
	}

	@Override
	public void propertyChange(PropertyChangeEvent arg) {
		if (arg.getPropertyName() == ConnectionFigure.REAL_POINTS_CHANGED && !updatingFigurePoints) {
			getModel().setPoints(Transform.yInverter.transform(getTransform().getInverseTransfrom().transform(Converter.convert(getFigure().getRealPoints()))));
		}
	}

	@Override
	protected void createEditPolicies() {
		installEditPolicy(EditPolicy.CONNECTION_BENDPOINTS_ROLE, new ConnectionBendpointPolicy(this));
		installEditPolicy(EditPolicy.CONNECTION_ROLE, new ConnectionPolicy(this));
	}

}
