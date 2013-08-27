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
	
	
	/**
	 * Makes a copy of this object, It will not be a "deep copy" nor a "shallow copy"
	 * some of the attributes might get cloned but not all. 
	 */
	@Override
	public Component clone() throws CloneNotSupportedException {
		Connector copy = (Connector)super.clone();
		copy.sourceConnections = new ArrayList<Connection>();
		copy.targetConnections = new ArrayList<Connection>();
		return copy;
	}
	
	public void addConnection(Connection c) {
		if (c.getSourceConnector() == this) {
			if (sourceConnections.add(c)) {
				notifyObservers(SOURCE_ADDED, c);
			}
		} else if (c.getTargetConnector() == this) {
			if (targetConnections.add(c)) {
				notifyObservers(TARGET_ADDED, c);
			}
		}
	}
	
	public void removeConnection(Connection c) {
		if (c.getSourceConnector() == this) {
			if (sourceConnections.remove(c)) {
				notifyObservers(SOURCE_REMOVED, c);
			}
		} else if (c.getTargetConnector() == this) {
			if (targetConnections.remove(c)) {
				notifyObservers(TARGET_REMOVED, c);
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
