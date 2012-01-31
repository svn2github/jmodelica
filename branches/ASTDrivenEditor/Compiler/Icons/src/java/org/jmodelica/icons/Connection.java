package org.jmodelica.icons;

import org.jmodelica.icons.primitives.Line;

public class Connection extends Line {
	
	private Connector sourceConnector;
	private Connector targetConnector;
	private boolean isConnected = true;

	public Connector getSourceConnector() {
		return sourceConnector;
	}
	
	public Connector getTargetConnector() {
		return targetConnector;
	}
	
	public void setSourceConnector(Connector sourceConnector) {
		this.sourceConnector = sourceConnector;
		if (isConnected)
			sourceConnector.addConnection(this);
	}
	
	public void setTargetConnector(Connector targetConnector) {
		this.targetConnector = targetConnector;
		if (isConnected)
			targetConnector.addConnection(this);
	}
	
	public void removeSourceConnector() {
		if (sourceConnector == null)
			return;
		if (isConnected)
			sourceConnector.removeConnection(this);
		sourceConnector = null;
	}
	
	public void removeTargetConnector() {
		if (targetConnector == null)
			return;
		if (isConnected)
			targetConnector.removeConnection(this);
		targetConnector = null;
	}
	
	public void connect() {
		if (isConnected)
			return;
		if (targetConnector != null)
			targetConnector.addConnection(this);
		if (sourceConnector != null)
			sourceConnector.addConnection(this);
		isConnected = true;
	}
	
	public void disconnect() {
		if (!isConnected)
			return;
		if (targetConnector != null)
			targetConnector.removeConnection(this);
		if (sourceConnector != null)
			sourceConnector.removeConnection(this);
		isConnected = false;
	}
	
}
