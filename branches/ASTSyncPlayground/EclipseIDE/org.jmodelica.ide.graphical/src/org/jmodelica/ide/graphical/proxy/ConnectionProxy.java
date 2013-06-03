package org.jmodelica.ide.graphical.proxy;

import java.util.List;
import java.util.Stack;

import org.jastadd.ed.core.model.IASTPathPart;
import org.jmodelica.icons.Observable;
import org.jmodelica.icons.Observer;
import org.jmodelica.icons.primitives.Color;
import org.jmodelica.icons.primitives.Line;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.modelica.compiler.ConnectClause;

public class ConnectionProxy extends Observable implements Observer {

	private AbstractDiagramProxy diagram;
	private ConnectorProxy source;
	private ConnectorProxy target;
	private boolean connected = true;
	private Stack<IASTPathPart> astPath;
	private Line syncGetConnectionLine;

	public ConnectionProxy(ConnectorProxy source, ConnectorProxy target,
			ConnectClause connectClause, AbstractDiagramProxy diagram) {
		this.source = source;
		this.target = target;
		this.diagram = diagram;
		syncGetConnectionLine = connectClause.syncGetConnectionLine();
		astPath = ModelicaASTRegistry.getInstance()
				.createDefPath(connectClause);
		source.addObserver(this);
		target.addObserver(this);
		source.sourceConnectionsHasChanged();
		target.targetConnectionsHasChanged();
	}

	public Line getLine() {
		/**
		 * if (connectClause == null) { ConnectionProxy newConnection =
		 * diagram.getConnection(source, target); if (newConnection == null)
		 * return null; else return newConnection.getLine(); }
		 */
		return syncGetConnectionLine;
	}

	public AbstractDiagramProxy getProxy() {
		return diagram;
	}

	public ConnectorProxy getSource() {
		return source;
	}

	public ConnectorProxy getTarget() {
		return target;
	}

	public void setColor(Color color) {
		getLine().setColor(color);
	}

	@SuppressWarnings("unchecked")
	@Override
	public void update(Observable o, Object flag, Object additionalInfo) {
		if (o == source && flag == ConnectorProxy.COLLECTING_SOURCE
				&& connected) {
			((List<ConnectionProxy>) additionalInfo).add(this);
		}
		if (o == target && flag == ConnectorProxy.COLLECTING_TARGET
				&& connected) {
			((List<ConnectionProxy>) additionalInfo).add(this);
		}
	}

	public Stack<IASTPathPart> getASTPath() {
		return astPath;
	}

	@Override
	public String toString() {
		return source.buildDiagramName() + " -- " + target.buildDiagramName();
	}

	protected void dispose() {
		source.removeObserver(this);
		target.removeObserver(this);
		connected = false;
	}
}