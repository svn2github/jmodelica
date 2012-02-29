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
	private boolean isConnected = false;
	
	public Connector getSourceConnector() {
		return sourceConnector;
	}
	
	public Connector getTargetConnector() {
		return targetConnector;
	}
	
	public void setSourceConnector(Connector newSourceConnector) {
		if (sourceConnector != null && isConnected) {
			sourceConnector.removeConnection(this);
			sourceConnector.removeObserver(this);
		}
		sourceConnector = newSourceConnector;
		if (isConnected) {
			if (newSourceConnector == null) {
				disconnect();
			} else {
				newSourceConnector.addConnection(this);
				newSourceConnector.addObserver(this);
			}
		}
		notifyObservers(SOURCE_ADDED);
	}
	
	public void setTargetConnector(Connector newTargetConnector) {
		if (targetConnector != null && isConnected) {
			targetConnector.removeConnection(this);
			targetConnector.removeObserver(this);
		}
		targetConnector = newTargetConnector;
		if (isConnected) {
			if (newTargetConnector == null) {
				disconnect();
			} else {
				newTargetConnector.addConnection(this);
				newTargetConnector.addObserver(this);
			}
		}
		notifyObservers(TARGET_ADDED);
		connect();
	}
	
	public void connect() {
		if (isConnected)
			return;
		if (sourceConnector == null || !sourceConnector.isAdded() || targetConnector == null || !targetConnector.isAdded())
			return;
		sourceConnector.addConnection(this);
		targetConnector.addConnection(this);
		isConnected = true;
		notifyObservers(CONNECTED);
	}
	
	public void disconnect() {
		if (!isConnected)
			return;
		if (sourceConnector != null) {
			sourceConnector.removeConnection(this);
		}
		if (targetConnector != null) {
			targetConnector.removeConnection(this);
		}
		isConnected = false;
		notifyObservers(DISCONNECTED);
	}
	
	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == sourceConnector && flag == Connector.IM_ADDED)
			connect();
		else if (o == targetConnector && flag == Connector.IM_ADDED)
			connect();
		else if (o == sourceConnector && flag == Connector.IM_REMOVED)
			disconnect();
		else if (o == targetConnector && flag == Connector.IM_REMOVED)
			disconnect();
		else
			super.update(o, flag, additionalInfo);
	}
	
}
