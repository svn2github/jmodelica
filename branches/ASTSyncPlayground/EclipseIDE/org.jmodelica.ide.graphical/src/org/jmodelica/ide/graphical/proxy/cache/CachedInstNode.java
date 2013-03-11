package org.jmodelica.ide.graphical.proxy.cache;

import java.util.ArrayList;
import java.util.List;
import org.jmodelica.icons.Layer;
import org.jmodelica.modelica.compiler.ConnectClause;
import org.jmodelica.modelica.compiler.FAbstractEquation;
import org.jmodelica.modelica.compiler.FConnectClause;
import org.jmodelica.modelica.compiler.InstComponentDecl;
import org.jmodelica.modelica.compiler.InstExtends;
import org.jmodelica.modelica.compiler.InstNode;

public abstract class CachedInstNode {
	private InstNode realInstNode;
	private List<CachedInstExtends> syncGetInstExtendss = new ArrayList<CachedInstExtends>();
	private Layer syncGetDiagramLayer;
	private Layer syncGetIconLayer;
	private List<CachedInstComponentDecl> syncGetInstComponentDecls = new ArrayList<CachedInstComponentDecl>();
	//private String syncLookupParameterValue; // TODO fix these
	protected List<CachedConnectClause> connectionClauses = new ArrayList<CachedConnectClause>();

	public CachedInstNode(InstNode node) {
		realInstNode = node;
		setSyncGetInstExtendss();
		syncGetDiagramLayer = node.syncGetDiagramLayer();
		syncGetIconLayer = node.syncGetIconLayer();
		setSyncGetInstComponentDecls();
		setConnectionClauses();
		// node.syncLookupParameterValue(parameter);
	}

	private void setConnectionClauses() {
		for (FAbstractEquation fae : realInstNode.syncGetFAbstractEquations()) {
			if (fae instanceof FConnectClause) {
				FConnectClause fcc = (FConnectClause) fae;
				ConnectClause connectClause = fcc.syncGetConnectClause();
				String c1 = fcc.syncGetConnector1().syncGetInstAccess()
						.syncMyInstComponentDecl().syncQualifiedName();
				String c2 = fcc.syncGetConnector2().syncGetInstAccess()
						.syncMyInstComponentDecl().syncQualifiedName();
				CachedConnectClause ccc = new CachedConnectClause(
						connectClause, c1, c2);
				connectionClauses.add(ccc);
			}
		}
	}

	private void setSyncGetInstComponentDecls() {
		for (InstComponentDecl icd : realInstNode.syncGetInstComponentDecls()) {
			syncGetInstComponentDecls.add(new CachedInstComponentDecl(icd));
		}
	}

	private void setSyncGetInstExtendss() {
		for (InstExtends ie : realInstNode.syncGetInstExtendss()) {
			syncGetInstExtendss.add(new CachedInstExtends(ie));
		}
	}

	public List<CachedInstExtends> syncGetInstExtendss() {
		return syncGetInstExtendss;
	}

	public Layer syncGetDiagramLayer() {
		return syncGetDiagramLayer;
	}

	public Layer syncGetIconLayer() {
		return syncGetIconLayer;
	}

	public List<CachedInstComponentDecl> syncGetInstComponentDecls() {
		return syncGetInstComponentDecls;
	}

	public List<CachedConnectClause> getConnections() {
		return connectionClauses;
	}

	/*
	 * public String syncLookupParameterValue(String parameter) { return
	 * syncLookupParameterValue; }
	 */
}
