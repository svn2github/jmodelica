package org.jmodelica.ide.graphical.proxy;

import java.util.ArrayList;
import java.util.List;

import org.jmodelica.icons.Observable;
import org.jmodelica.modelica.compiler.InstComponentDecl;

public abstract class ConnectorProxy extends ComponentProxy {

	public static final Object SOURCE_CONNECTIONS_HAS_CHANGED = "Source connections has changed";
	public static final Object TARGET_CONNECTIONS_HAS_CHANGED = "Target connections has changed";
	protected static final Object COLLECTING_SOURCE = new Object();
	protected static final Object COLLECTING_TARGET = new Object();

	public ConnectorProxy(InstComponentDecl icdc, String componentName,
			AbstractNodeProxy parent) {
		super(icdc, componentName, parent);
	}

	public List<ConnectionProxy> getSourceConnections() {
		List<ConnectionProxy> connections = new ArrayList<ConnectionProxy>();
		notifyObservers(COLLECTING_SOURCE, connections);
		return connections;
	}

	public List<ConnectionProxy> getTargetConnections() {
		List<ConnectionProxy> connections = new ArrayList<ConnectionProxy>();
		notifyObservers(COLLECTING_TARGET, connections);
		return connections;
	}

	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getParent() && flag == COLLECT_CONNECTIONS) {
			@SuppressWarnings("unchecked")
			List<ConnectionProxy> connectionList = (List<ConnectionProxy>) additionalInfo;
			connectionList.addAll(getSourceConnections());
			connectionList.addAll(getTargetConnections());
		}
		super.update(o, flag, additionalInfo);
	}

	public void sourceConnectionsHasChanged() {
		notifyObservers(SOURCE_CONNECTIONS_HAS_CHANGED);
	}

	public void targetConnectionsHasChanged() {
		notifyObservers(TARGET_CONNECTIONS_HAS_CHANGED);
	}

	@Override
	public boolean isConnector() {
		return true;
	}
}