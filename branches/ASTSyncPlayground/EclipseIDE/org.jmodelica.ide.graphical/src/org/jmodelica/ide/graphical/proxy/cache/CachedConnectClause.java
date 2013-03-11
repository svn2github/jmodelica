package org.jmodelica.ide.graphical.proxy.cache;

import org.jmodelica.icons.primitives.Line;
import org.jmodelica.modelica.compiler.ConnectClause;

public class CachedConnectClause {
	private ConnectClause realConnectClause;
	private String connInstCompQName1;
	private String connInstCompQName2;
	private Line syncGetConnectionLine;

	public CachedConnectClause(ConnectClause cc, String connInstComp1QName,
			String connInstComp2QName) {
		this.realConnectClause = cc;
		this.connInstCompQName1 = connInstComp1QName;
		this.connInstCompQName2 = connInstComp2QName;
		syncGetConnectionLine = cc.syncGetConnectionLine();
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
