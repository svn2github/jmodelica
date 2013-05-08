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
	private List<CachedInstExtends> syncGetInstExtendss = new ArrayList<CachedInstExtends>();
	private Layer cacheDiagramLayer;
	private Layer cacheIconLayer;
	private List<CachedInstComponentDecl> syncGetInstComponentDecls = new ArrayList<CachedInstComponentDecl>();
	protected List<CachedConnectClause> connectionClauses = new ArrayList<CachedConnectClause>();

	public CachedInstNode(InstNode node) {
		setSyncGetInstExtendss(node);
		cacheDiagramLayer = node.cacheDiagramLayer();
		cacheIconLayer = node.cacheIconLayer();
		setSyncGetInstComponentDecls(node);
		setConnectionClauses(node);
	}

	private void setConnectionClauses(InstNode node) {
		for (FAbstractEquation fae : node.syncGetFAbstractEquations()) {
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

	private void setSyncGetInstComponentDecls(InstNode node) {
		for (InstComponentDecl icd : node.syncGetInstComponentDecls()) {
			syncGetInstComponentDecls.add(new CachedInstComponentDecl(icd));
		}
	}

	private void setSyncGetInstExtendss(InstNode node) {
		for (InstExtends ie : node.syncGetInstExtendss()) {
			syncGetInstExtendss.add(new CachedInstExtends(ie));
		}
	}

	public List<CachedInstExtends> syncGetInstExtendss() {
		return syncGetInstExtendss;
	}

	public Layer syncGetDiagramLayer() {
		return cacheDiagramLayer;
	}

	public Layer syncGetIconLayer() {
		return cacheIconLayer;
	}

	public List<CachedInstComponentDecl> syncGetInstComponentDecls() {
		return syncGetInstComponentDecls;
	}

	public List<CachedConnectClause> getConnections() {
		return connectionClauses;
	}
}