package org.jmodelica.ide.graphical.edit.parts;

import java.util.List;

import org.eclipse.draw2d.ChopboxAnchor;
import org.eclipse.draw2d.ConnectionAnchor;
import org.eclipse.draw2d.IFigure;
import org.eclipse.gef.ConnectionEditPart;
import org.eclipse.gef.DragTracker;
import org.eclipse.gef.EditPolicy;
import org.eclipse.gef.NodeEditPart;
import org.eclipse.gef.Request;
import org.eclipse.gef.tools.ConnectionDragCreationTool;
import org.jmodelica.icons.Observable;
import org.jmodelica.ide.graphical.edit.policies.ConnectorPolicy;
import org.jmodelica.ide.graphical.proxy.ConnectionProxy;
import org.jmodelica.ide.graphical.proxy.ConnectorProxy;

public class ConnectorPart extends ComponentPart implements NodeEditPart {

	private ChopboxAnchor anchor;
	
	public ConnectorPart(ConnectorProxy cp) {
		super(cp);
	}
	
	@Override
	protected void setFigure(IFigure figure) {
		super.setFigure(figure);
		figure.setOpaque(true);
		anchor = new ChopboxAnchor(figure);
	}
	
	@Override
	public ConnectorProxy getModel() {
		return (ConnectorProxy) super.getModel();
	}
	
	@Override
	protected List<ConnectionProxy> getModelSourceConnections() {
		return getModel().getSourceConnections();
	}
	
	@Override
	protected List<ConnectionProxy> getModelTargetConnections() {
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
	protected void createEditPolicies() {
		super.createEditPolicies();
		installEditPolicy(EditPolicy.GRAPHICAL_NODE_ROLE, new ConnectorPolicy(this));
	}
	
	@Override
	public DragTracker getDragTracker(Request request) {
		return new ConnectionDragCreationTool();
	}
	
	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getModel() && flag == ConnectorProxy.SOURCE_CONNECTIONS_HAS_CHANGED)
			refreshSourceConnections();
		else if (o == getModel() && flag == ConnectorProxy.TARGET_CONNECTIONS_HAS_CHANGED)
			refreshTargetConnections();
		super.update(o, flag, additionalInfo);
	}
	
}
