package org.jmodelica.icons;

import java.util.ArrayList;

import org.jmodelica.icons.drawing.IconConstants.Context;

public class Diagram extends Icon implements Observer {
	
	public static final Object CONNECTION_ADDED = new Object();
	public static final Object CONNECTION_REMOVED = new Object();
	
	private ArrayList<Connection> connections = new ArrayList<Connection>();
	
	public Diagram(String className, Layer layer, Context context) {
		super(className, layer, context);
	}
	
	public void addConnection(Connection con) {
		if (!connections.contains(con) && connections.add(con)) {
			con.addObserver(this);
			notifyObservers(CONNECTION_ADDED, con);
		}
	}
	
	public ArrayList<Connection> getConnections() {
		return connections;
	}
	
	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o instanceof Connection) {
			if (flag == Connection.CONNECTED && !connections.contains(o) && connections.add((Connection) o)) {
				notifyObservers(CONNECTION_ADDED, o);
			} else if (flag == Connection.DISCONNECTED && connections.remove(o)) {
				notifyObservers(CONNECTION_REMOVED, o);
			}
		}
	}

}
