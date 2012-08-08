package org.jmodelica.ide.graphical.proxy;

import java.util.List;

import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;
import org.jmodelica.icons.primitives.Color;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.modelica.compiler.ConnectClause;

public class ConnectionProxy extends Observable implements Observer {

	private AbstractDiagramProxy diagram;
	private ConnectorProxy source;
	private ConnectorProxy target;
	private ConnectClause connectClause;
	private boolean connected = true;

	public ConnectionProxy(ConnectorProxy source, ConnectorProxy target, ConnectClause connectClause, AbstractDiagramProxy diagram) {
		this.source = source;
		this.target = target;
		this.connectClause = connectClause;
		this.diagram = diagram;
		source.addObserver(this);
		target.addObserver(this);
		source.sourceConnectionsHasChanged();
		target.targetConnectionsHasChanged();
	}

	public Line getLine() {
		return connectClause.syncGetConnectionLine();
	}

	public void disconnect() {
		if (!connected)
			return;
		diagram.removeConnection(this);
		connected = false;
		source.sourceConnectionsHasChanged();
		target.targetConnectionsHasChanged();
	}

	public void connect() {
		if (connected)
			return;
		diagram.addConnection(this);
		connected = true;
		source.sourceConnectionsHasChanged();
		target.targetConnectionsHasChanged();
	}

	public ConnectorProxy getSource() {
		return source;
	}

	public ConnectorProxy getTarget() {
		return target;
	}

	public void setColor(Color color) {
		getLine().setColor(color);
	}

	@SuppressWarnings("unchecked")
	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == source && flag == ConnectorProxy.COLLECTING_SOURCE && connected) {
			((List<ConnectionProxy>) additionalInfo).add(this);
		}
		if (o == target && flag == ConnectorProxy.COLLECTING_TARGET && connected) {
			((List<ConnectionProxy>) additionalInfo).add(this);
		}
	}

	protected ConnectClause getConnectClause() {
		return connectClause;
	}
	
	@Override
	public String toString() {
		return source.buildDiagramName() + " -- " + target.buildDiagramName();
	}

}
