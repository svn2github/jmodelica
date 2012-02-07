package org.jmodelica.icons;

import java.util.ArrayList;

import org.jmodelica.icons.coord.Placement;

public class Connector extends Component {
	
	public static final Object SOURCE_ADDED = new Object();
	public static final Object SOURCE_REMOVED = new Object();
	public static final Object TARGET_ADDED = new Object();
	public static final Object TARGET_REMOVED = new Object();
	
	private ArrayList<Connection> sourceConnections = new ArrayList<Connection>();
	private ArrayList<Connection> targetConnections = new ArrayList<Connection>();

	public Connector(Icon icon, Placement placement) {
		super(icon, placement);
	}
	
	public Connector(Icon icon, Placement placement, String componentName) {
		super(icon, placement, componentName);
	}
	
	public void addConnection(Connection c) {
		if (c.getSourceConnector() == this) {
			if (sourceConnections.add(c)) {
				notifyObservers(SOURCE_ADDED);
			}
		} else if (c.getTargetConnector() == this) {
			if (targetConnections.add(c)) {
				notifyObservers(TARGET_ADDED);
			}
		}
	}
	
	public void removeConnection(Connection c) {
		if (c.getSourceConnector() == this) {
			if (sourceConnections.remove(c)) {
				notifyObservers(SOURCE_REMOVED);
			}
		} else if (c.getTargetConnector() == this) {
			if (targetConnections.remove(c)) {
				notifyObservers(TARGET_REMOVED);
			}
		}
	}
	
	public ArrayList<Connection> getSourceConnections() {
		return sourceConnections;
	}
	
	public ArrayList<Connection> getTargetConnections() {
		return targetConnections;
	}
	
}
