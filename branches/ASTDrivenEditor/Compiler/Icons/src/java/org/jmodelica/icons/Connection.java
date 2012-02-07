package org.jmodelica.icons;

import org.jmodelica.icons.primitives.Line;

public class Connection extends Line {
	
	public static final Object CONNECTED = new Object();
	public static final Object DISCONNECTED = new Object();
	public static final Object SOURCE_ADDED = new Object();
	public static final Object SOURCE_REMOVED = new Object();
	public static final Object TARGET_ADDED = new Object();
	public static final Object TARGET_REMOVED = new Object();
	
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
		removeSourceConnector();
		this.sourceConnector = sourceConnector;
		if (isConnected)
			sourceConnector.addConnection(this);
		notifyObservers(SOURCE_ADDED);
	}
	
	public void setTargetConnector(Connector targetConnector) {
		removeTargetConnector();
		this.targetConnector = targetConnector;
		if (isConnected)
			targetConnector.addConnection(this);
		notifyObservers(TARGET_ADDED);
	}
	
	public void removeSourceConnector() {
		if (sourceConnector == null)
			return;
		if (isConnected)
			sourceConnector.removeConnection(this);
		sourceConnector = null;
		notifyObservers(SOURCE_REMOVED);
	}
	
	public void removeTargetConnector() {
		if (targetConnector == null)
			return;
		if (isConnected)
			targetConnector.removeConnection(this);
		targetConnector = null;
		notifyObservers(TARGET_REMOVED);
	}
	
	public void connect() {
		if (isConnected)
			return;
		if (targetConnector != null)
			targetConnector.addConnection(this);
		if (sourceConnector != null)
			sourceConnector.addConnection(this);
		isConnected = true;
		notifyObservers(CONNECTED);
	}
	
	public void disconnect() {
		if (!isConnected)
			return;
		if (targetConnector != null)
			targetConnector.removeConnection(this);
		if (sourceConnector != null)
			sourceConnector.removeConnection(this);
		isConnected = false;
		notifyObservers(DISCONNECTED);
	}
	
}
