package org.jmodelica.icons;

import java.util.ArrayList;

import org.jmodelica.icons.drawing.IconConstants.Context;

public class Diagram extends Icon {
	
	private ArrayList<Connection> connections = new ArrayList<Connection>();
	
	public Diagram(String className, Layer layer, Context context) {
		super(className, layer, context);
	}
	
	public void addConnection(Connection con) {
		connections.add(con);
	}
	
	public ArrayList<Connection> getConnections() {
		return connections;
	}

}
