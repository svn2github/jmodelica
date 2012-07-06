package org.jmodelica.ide.graphical.editparts;

import java.util.List;

import org.eclipse.draw2d.ChopboxAnchor;
import org.eclipse.draw2d.ConnectionAnchor;
import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.PositionConstants;
import org.eclipse.gef.ConnectionEditPart;
import org.eclipse.gef.DragTracker;
import org.eclipse.gef.EditPolicy;
import org.eclipse.gef.NodeEditPart;
import org.eclipse.gef.Request;
import org.eclipse.gef.RequestConstants;
import org.eclipse.gef.commands.Command;
import org.eclipse.gef.editpolicies.GraphicalNodeEditPolicy;
import org.eclipse.gef.requests.CreateConnectionRequest;
import org.eclipse.gef.requests.ReconnectRequest;
import org.eclipse.gef.tools.ConnectionDragCreationTool;
import org.jmodelica.icons.Connection;
import org.jmodelica.icons.Connector;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.coord.Extent;
import org.jmodelica.icons.coord.Point;
import org.jmodelica.ide.graphical.commands.CreateConnectionCommand;
import org.jmodelica.ide.graphical.graphics.TemporaryConnectionFigure;
import org.jmodelica.ide.graphical.util.ASTResourceProvider;
import org.jmodelica.ide.graphical.util.Converter;

public class ConnectorEditPart extends ComponentEditPart implements NodeEditPart {

	ChopboxAnchor anchor;

	public ConnectorEditPart(Connector connector, ASTResourceProvider provider) {
		super(connector, provider);
	}

	@Override
	public Connector getModel() {
		return (Connector) super.getModel();
	}

	@Override
	public void activate() {
		super.activate();
		getModel().addObserver(this);
	}

	@Override
	public void deactivate() {
		getModel().removeObserver(this);
		super.deactivate();
	}

	@Override
	protected void setFigure(IFigure figure) {
		super.setFigure(figure);
		figure.setOpaque(true);
		anchor = new ChopboxAnchor(figure);
	}

	@Override
	protected void createEditPolicies() {
		super.createEditPolicies();
		installEditPolicy(EditPolicy.GRAPHICAL_NODE_ROLE, new GraphicalNodeEditPolicy() {
			@Override
			protected TemporaryConnectionFigure createDummyConnection(Request req) {
				TemporaryConnectionFigure tcf = new TemporaryConnectionFigure();
				tcf.setForegroundColor(Converter.convert(calculateConnectionColor()));
				tcf.setSourceDirection(((ConnectorEditPart) ((CreateConnectionRequest) req).getSourceEditPart()).calculateConnectorLocation());
				return tcf;
			}

			@Override
			public void showSourceFeedback(Request request) {
				super.showSourceFeedback(request);
				if (RequestConstants.REQ_CONNECTION_END.equals(request.getType())) {
					CreateConnectionRequest ccr = (CreateConnectionRequest) request;
					TemporaryConnectionFigure tcf = (TemporaryConnectionFigure) connectionFeedback;

					if (ccr.getTargetEditPart() == null) {
						tcf.setTargetDirection(PositionConstants.NONE);
					} else {
						ConnectorEditPart cep = (ConnectorEditPart) ccr.getTargetEditPart();
						tcf.setTargetDirection(cep.calculateConnectorLocation());
					}
				}
			}

			@Override
			protected Command getConnectionCreateCommand(CreateConnectionRequest request) {
				Connector source = (Connector) ((ConnectorEditPart) getHost()).getModel();
				CreateConnectionCommand cmd = new CreateConnectionCommand(source) {

					@Override
					protected void initConnection(Connection c) {
						c.setColor(calculateConnectionColor());
					}

				};
				request.setStartCommand(cmd);
				return cmd;
			}

			@Override
			protected Command getConnectionCompleteCommand(CreateConnectionRequest request) {
				CreateConnectionCommand cmd = (CreateConnectionCommand) request.getStartCommand();
				cmd.setTarget((Connector) ((ConnectorEditPart) getHost()).getModel());
				return cmd;
			}

			@Override
			protected Command getReconnectSourceCommand(ReconnectRequest request) {
				return null;
//				Connection conn = (Connection) request.getConnectionEditPart().getModel();
//				Shape newSource = (Shape) getHost().getModel();
//				ConnectionReconnectCommand cmd = new ConnectionReconnectCommand(conn);
//				cmd.setNewSource(newSource);
//				return cmd;
			}

			@Override
			protected Command getReconnectTargetCommand(ReconnectRequest request) {
				return null;
//				Connection conn = (Connection) request.getConnectionEditPart().getModel();
//				Shape newTarget = (Shape) getHost().getModel();
//				ConnectionReconnectCommand cmd = new ConnectionReconnectCommand(conn);
//				cmd.setNewTarget(newTarget);
//				return cmd;
			}
		});
	}

	@Override
	public DragTracker getDragTracker(Request request) {
		return new ConnectionDragCreationTool();
	}

	@Override
	public List<Connection> getModelSourceConnections() {
		return getModel().getSourceConnections();
	}

	@Override
	public List<Connection> getModelTargetConnections() {
		return getModel().getTargetConnections();
	}

	@Override
	public ConnectionAnchor getSourceConnectionAnchor(ConnectionEditPart connection) {
		return anchor;
	}

	@Override
	public ConnectionAnchor getTargetConnectionAnchor(ConnectionEditPart connection) {
		return anchor;
	}

	@Override
	public ConnectionAnchor getSourceConnectionAnchor(Request request) {
		return anchor;
	}

	@Override
	public ConnectionAnchor getTargetConnectionAnchor(Request request) {
		return anchor;
	}

	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getModel() && (flag == Connector.SOURCE_ADDED || flag == Connector.SOURCE_REMOVED))
			refreshSourceConnections();
		else if (o == getModel() && (flag == Connector.TARGET_ADDED || flag == Connector.TARGET_REMOVED))
			refreshTargetConnections();
		else
			super.update(o, flag, additionalInfo);
	}

	public int calculateConnectorLocation() {
		Extent e = getParent().getIcon().getExtent();
		int loc = PositionConstants.NONE;

		Point bl = e.getBottomLeft();

		Point p = getModel().getPlacement().getTransformation().getOrigin();
		Point p2 = getModel().getPlacement().getTransformation().getExtent().getMiddle();
		double xProcent = (p.getX() + p2.getX() - bl.getX()) / e.getWidth();
		if (xProcent <= 0.25)
			loc |= PositionConstants.WEST;
		else if (xProcent >= 0.75)
			loc |= PositionConstants.EAST;

		double yProcent = (p.getY() + p2.getY() - bl.getY()) / e.getHeight();
		if (yProcent <= 0.25)
			loc |= PositionConstants.SOUTH;
		else if (yProcent >= 0.75)
			loc |= PositionConstants.NORTH;
		loc = getParentTransform().getInverseTransfrom().transformDirection(loc);
		return loc;
	}

}
