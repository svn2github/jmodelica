package org.jmodelica.ide.graphical.proxy.cache;

import java.util.Stack;

import org.jmodelica.icons.primitives.Line;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.modelica.compiler.ConnectClause;

public class CachedConnectClause {
	private String connInstCompQName1;
	private String connInstCompQName2;
	private Line syncGetConnectionLine;
	private Stack<String> astPath = new Stack<String>();

	public CachedConnectClause(ConnectClause cc, String connInstComp1QName,
			String connInstComp2QName) {
		this.connInstCompQName1 = connInstComp1QName;
		this.connInstCompQName2 = connInstComp2QName;
		syncGetConnectionLine = cc.syncGetConnectionLine();
		astPath = ModelicaASTRegistry.getInstance().createPath(cc);
	}

	public Stack<String> getConnectClauseASTPath() {
		return astPath;
	}

	public String getConnInstComp1QName() {
		return connInstCompQName1;
	}

	public String getConnInstComp2QName() {
		return connInstCompQName2;
	}

	public Line syncGetConnectionLine() {
		return syncGetConnectionLine;
	}
}
