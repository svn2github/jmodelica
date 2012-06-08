package org.jmodelica.ide.graphical.editparts;

import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;

import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.XYAnchor;
import org.eclipse.draw2d.geometry.Point;
import org.eclipse.draw2d.geometry.PointList;
import org.eclipse.gef.EditPart;
import org.eclipse.gef.EditPolicy;
import org.eclipse.gef.LayerConstants;
import org.eclipse.gef.commands.Command;
import org.eclipse.gef.editpolicies.BendpointEditPolicy;
import org.eclipse.gef.editpolicies.ConnectionEditPolicy;
import org.eclipse.gef.requests.BendpointRequest;
import org.eclipse.gef.requests.GroupRequest;
import org.jmodelica.icons.Connection;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.primitives.Color;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.ide.graphical.commands.CreateBendpointCommand;
import org.jmodelica.ide.graphical.commands.DeleteBendpointCommand;
import org.jmodelica.ide.graphical.commands.DeleteConnectionCommand;
import org.jmodelica.ide.graphical.commands.MoveBendpointCommand;
import org.jmodelica.ide.graphical.editparts.primitives.LineEditPart;
import org.jmodelica.ide.graphical.graphics.ConnectionFigure;
import org.jmodelica.ide.graphical.util.Converter;
import org.jmodelica.ide.graphical.util.Transform;

public class ConnectionEditPart extends LineEditPart implements org.eclipse.gef.ConnectionEditPart, PropertyChangeListener {

	private ConnectorEditPart sourceEditPart;
	private ConnectorEditPart targetEditPart;
	private boolean updatingFigurePoints = false;

	public ConnectionEditPart(Connection model) {
		super(model);
	}

	@Override
	protected IFigure createFigure() {
		ConnectionFigure cf = new ConnectionFigure();
		cf.addPropertyChangeListener(ConnectionFigure.REAL_POINTS_CHANGED, this);
		return cf;
	}

	@Override
	protected void setFigurePoints(PointList points) {
		updatingFigurePoints = true;
		getFigure().setRealPoints(points);
		updatingFigurePoints = false;
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
	public ConnectionFigure getFigure() {
		return (ConnectionFigure) super.getFigure();
	}

	@Override
	public Connection getModel() {
		return (Connection) super.getModel();
	}

	@Override
	public void setParent(EditPart parent) {
		while (parent != null && !(parent instanceof DiagramEditPart)) {
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
	public ConnectorEditPart getSource() {
		return sourceEditPart;
	}

	@Override
	public ConnectorEditPart getTarget() {
		return targetEditPart;
	}

	@Override
	public void setSource(EditPart source) {
		if (source == sourceEditPart)
			return;
		if (!(source instanceof ConnectorEditPart))
			source = null;
		sourceEditPart = (ConnectorEditPart) source;
		if (sourceEditPart != null) {
			setParent(sourceEditPart);
		} else if (getTarget() == null) {
			setParent(null);
		}
		if (sourceEditPart != null && getTarget() != null)
			refresh();
	}

	@Override
	public void setTarget(EditPart target) {
		if (target == targetEditPart)
			return;
		if (!(target instanceof ConnectorEditPart))
			target = null;
		targetEditPart = (ConnectorEditPart) target;
		if (targetEditPart != null) {
			setParent(targetEditPart);
		} else if (getSource() == null) {
			setParent(null);
		}
		if (targetEditPart != null && getSource() != null)
			refresh();
	}

	@Override
	public DiagramEditPart getParent() {
		return (DiagramEditPart) super.getParent();
	}

	@Override
	protected Transform getTransform() {
		return getParent().getTransform();
	}

	@Override
	protected void createEditPolicies() {
		installEditPolicy(EditPolicy.CONNECTION_BENDPOINTS_ROLE, new BendpointEditPolicy() {

			@Override
			protected Command getMoveBendpointCommand(final BendpointRequest request) {
				return new MoveBendpointCommand(ConnectionEditPart.this.getModel()) {

					@Override
					protected org.jmodelica.icons.coord.Point calculateOldPoint() {
						return getModel().getPoints().get(request.getIndex() + 1);
					}

					@Override
					protected org.jmodelica.icons.coord.Point calculateNewPoint() {
						Point location = request.getLocation();
						getFigure().translateToRelative(location);
						return Transform.yInverter.transform(getTransform().getInverseTransfrom().transform(Converter.convert(location)));
					}

				};
			}

			@Override
			protected Command getDeleteBendpointCommand(final BendpointRequest request) {
				return new DeleteBendpointCommand(ConnectionEditPart.this.getModel()) {

					@Override
					protected org.jmodelica.icons.coord.Point calculateOldPoint() {
						return getModel().getPoints().get(request.getIndex() + 1);
					}
				};
			}

			@Override
			protected Command getCreateBendpointCommand(final BendpointRequest request) {
				return new CreateBendpointCommand(ConnectionEditPart.this.getModel()) {

					@Override
					protected int calculateIndex() {
						return request.getIndex() + 1;
					}

					@Override
					protected org.jmodelica.icons.coord.Point calculateNewPoint() {
						Point location = request.getLocation();
						getFigure().translateToRelative(location);
						return Transform.yInverter.transform(getTransform().getInverseTransfrom().transform(Converter.convert(location)));
					}
				};
			}
		});
		installEditPolicy(EditPolicy.CONNECTION_ROLE, new ConnectionEditPolicy() {

			@Override
			protected Command getDeleteCommand(GroupRequest request) {
				return new DeleteConnectionCommand(getModel());
			}
		});
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
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getModel())
			refresh();
		super.update(o, flag, additionalInfo);
	}

	@Override
	protected void updateColor() {
		Color c = getModel().getColor();
		if (c == Line.DEFAULT_COLOR && getSource() != null)
			c = getSource().calculateConnectionColor();
		if (c == Line.DEFAULT_COLOR && getTarget() != null)
			c = getTarget().calculateConnectionColor();
		getFigure().setForegroundColor(Converter.convert(c));
	}

	@Override
	public void propertyChange(PropertyChangeEvent arg) {
		if (arg.getPropertyName() == ConnectionFigure.REAL_POINTS_CHANGED && updatingFigurePoints == false) {
			getModel().setPoints(Transform.yInverter.transform(getTransform().getInverseTransfrom().transform(Converter.convert(getFigure().getRealPoints()))));
		}

	}

}
