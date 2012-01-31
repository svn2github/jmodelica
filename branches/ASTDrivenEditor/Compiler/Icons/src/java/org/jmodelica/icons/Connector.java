package org.jmodelica.icons;

import java.util.ArrayList;

import org.jmodelica.icons.coord.Placement;

public class Connector extends Component {
	
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
			sourceConnections.add(c);
		} else if (c.getTargetConnector() == this) {
			targetConnections.add(c);
		}
	}
	
	public void removeConnection(Connection c) {
		if (c.getSourceConnector() == this) {
			sourceConnections.remove(c);
		} else if (c.getTargetConnector() == this) {
			targetConnections.remove(c);
		}
	}
	
	public ArrayList<Connection> getSourceConnections() {
		return sourceConnections;
	}
	
	public ArrayList<Connection> getTargetConnections() {
		return targetConnections;
	}
	
}
