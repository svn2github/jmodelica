package org.jmodelica.ide.graphical.proxy;

import java.util.List;

import org.jmodelica.icons.Observable;


public abstract class ConnectorProxy extends ComponentProxy {
	
	public static final Object SOURCE_CONNECTIONS_HAS_CHANGED = "Source connections has changed";
	public static final Object TARGET_CONNECTIONS_HAS_CHANGED = "Target connections has changed";
	
	public ConnectorProxy(String componentName, AbstractNodeProxy parent) {
		super(componentName, parent);
	}
	
	public List<ConnectionProxy> getSourceConnections() {
		return getDiagram().getSourceConnectionsFor(getComponentDecl());
	}
	
	public List<ConnectionProxy> getTargetConnections() {
		return getDiagram().getTargetConnectionsFor(getComponentDecl());
	}
	
	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == getParent() && flag == COLLECT_CONNECTIONS) {
			@SuppressWarnings("unchecked")
			List<ConnectionProxy> connectionList = (List<ConnectionProxy>) additionalInfo;
			for (ConnectionProxy connection : getSourceConnections()) {
				connectionList.add(connection);
			}
			for (ConnectionProxy connection : getTargetConnections()) {
				connectionList.add(connection);
			}
		}
		super.update(o, flag, additionalInfo);
	}

	public void sourceConnectionsHasChanged() {
		notifyObservers(SOURCE_CONNECTIONS_HAS_CHANGED);
	}

	public void targetConnectionsHasChanged() {
		notifyObservers(TARGET_CONNECTIONS_HAS_CHANGED);
	}
}
