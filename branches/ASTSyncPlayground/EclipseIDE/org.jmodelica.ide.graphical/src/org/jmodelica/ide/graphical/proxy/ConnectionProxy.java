package org.jmodelica.ide.graphical.proxy;

import java.util.List;

import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;
import org.jmodelica.icons.primitives.Color;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.ide.graphical.proxy.cache.CachedConnectClause;

public class ConnectionProxy extends Observable implements Observer {

	private AbstractDiagramProxy diagram;
	private ConnectorProxy source;
	private ConnectorProxy target;
	private CachedConnectClause connectClause;
	private boolean connected = true;

	public ConnectionProxy(ConnectorProxy source, ConnectorProxy target,
			CachedConnectClause connectClause, AbstractDiagramProxy diagram) {
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
		if (connectClause == null) {
			ConnectionProxy newConnection = diagram.getConnection(source,
					target);
			if (newConnection == null)
				return null;
			else
				return newConnection.getLine();
		}
		return connectClause.syncGetConnectionLine();
	}

	public void disconnect(int undoActionId) {
		if (!connected)
			return;
		diagram.removeConnection(this, undoActionId);
		connected = false;
		source.sourceConnectionsHasChanged();
		target.targetConnectionsHasChanged();
	}

	public AbstractDiagramProxy getProxy() {
		return diagram;
	}

	/**public void connect() {
		if (connected)
			return;
		diagram.addConnection(this);
		connected = true;
		source.sourceConnectionsHasChanged();
		target.targetConnectionsHasChanged();
	}*/

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
		if (o == source && flag == ConnectorProxy.COLLECTING_SOURCE
				&& connected) {
			((List<ConnectionProxy>) additionalInfo).add(this);
		}
		if (o == target && flag == ConnectorProxy.COLLECTING_TARGET
				&& connected) {
			((List<ConnectionProxy>) additionalInfo).add(this);
		}
	}

	public CachedConnectClause getConnectClause() {
		return connectClause;
	}

	@Override
	public String toString() {
		return source.buildDiagramName() + " -- " + target.buildDiagramName();
	}

	protected void dispose() {
		source.removeObserver(this);
		target.removeObserver(this);
		connected = false;
		connectClause = null;
	}
}
