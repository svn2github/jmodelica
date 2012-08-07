package org.jmodelica.ide.graphical.proxy;

import java.util.Arrays;

import org.jmodelica.icons.coord.Point;
import org.jmodelica.icons.primitives.Color;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.modelica.compiler.FConnectClause;

public class ConnectionProxy {

	private AbstractDiagramProxy diagram;
	private String sourceID;
	private String targetID;
	private boolean connected = true;
	private Line lineCache;

	public ConnectionProxy(String sourceID, String targetID, AbstractDiagramProxy diagram) {
		this(sourceID, targetID, diagram, true);
	}

	public ConnectionProxy(String sourceID, String targetID, AbstractDiagramProxy diagram, boolean connected) {
		this.sourceID = sourceID;
		this.targetID = targetID;
		this.diagram = diagram;
		this.connected = connected;
	}

	private FConnectClause getFConnectClause() {
		return diagram.getConnection(sourceID, targetID);
	}

	public Line getLine() {
		if (connected)
			return getFConnectClause().getConnectionLine();
		if (lineCache == null)
			lineCache = new Line(Arrays.asList(new Point(), new Point()));
		return lineCache;
	}

	public void disconnect() {
		if (!connected)
			return;
		lineCache = getLine();
		if (diagram.removeConnection(sourceID, targetID))
			connected = false;
	}

	public void connect() {
		if (connected)
			return;
		diagram.addConnection(sourceID, targetID, getLine());
		lineCache = null;
		connected = true;
	}

	public String getSourceID() {
		return sourceID;
	}

	public String getTargetID() {
		return targetID;
	}

	public void setColor(Color color) {
		getLine().setColor(color);
	}

}
