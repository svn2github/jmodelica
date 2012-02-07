package org.jmodelica.icons;

import java.util.ArrayList;

import org.jmodelica.icons.drawing.IconConstants.Context;

public class Diagram extends Icon {
	
	public static final Object CONNECTION_ADDED = new Object();
	public static final Object CONNECTION_REMOVED = new Object();
	
	private ArrayList<Connection> connections = new ArrayList<Connection>();
	
	public Diagram(String className, Layer layer, Context context) {
		super(className, layer, context);
	}
	
	public void addConnection(Connection con) {
		connections.add(con);
		notifyObservers(CONNECTION_ADDED);
	}
	
	public ArrayList<Connection> getConnections() {
		return connections;
	}

}
