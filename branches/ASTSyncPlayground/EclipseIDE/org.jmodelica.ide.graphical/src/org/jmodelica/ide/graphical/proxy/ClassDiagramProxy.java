package org.jmodelica.ide.graphical.proxy;

import java.io.ByteArrayInputStream;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.ide.compiler.IJobObject;
import org.jmodelica.ide.compiler.ModelicaASTRegistryJobBucket;
import org.jmodelica.ide.compiler.ModificationJob;
import org.jmodelica.ide.graphical.proxy.cache.CachedInstClassDecl;
import org.jmodelica.ide.graphical.proxy.cache.CachedInstComponentDecl;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class ClassDiagramProxy extends AbstractDiagramProxy {

	public static final Object COMPONENT_ADDED = new Object();
	public static final Object COMPONENT_REMOVED = new Object();
	public static final Object FLUSH_CONTENTS = new String("Flush contents now");

	private InstClassDecl realInstClassDecl;
	private CachedInstClassDecl instClassDecl;
	private IFile theFile;

	public ClassDiagramProxy(IFile theFile, InstClassDecl icd) {
		this.theFile = theFile;
		realInstClassDecl = icd;
		instClassDecl = new CachedInstClassDecl(realInstClassDecl);
	}

	protected InstClassDecl getRealASTNode() {
		return realInstClassDecl;
	}

	@Override
	protected CachedInstClassDecl getASTNode() {
		return instClassDecl;
	}

	public void setInstClassDeclCached(CachedInstClassDecl icdc) {
		this.instClassDecl = icdc;
	}

	@Override
	protected CachedInstComponentDecl getComponentDecl() {
		return null;
	}

	@Override
	protected CachedInstClassDecl getClassDecl() {
		return getASTNode();
	}

	public String getDefinitionKey() {
		// synchronized (instClassDecl.state()) {//TODO remove
		return instClassDecl.getDefinitionKey();
		// }
	}

	@Override
	public ComponentProxy addComponent(String className, String componentName,
			Placement placement) {
		System.out.println("GRAPHICAL: adding node to component "
				+ getRealASTNode().getNodeName());
		/*
		 * String mapName; InstComponentDeclCached icd =
		 * getASTNode().syncAddComponent(className, componentName, placement);
		 * mapName = buildMapName(icd.syncQualifiedName(),
		 * icd.syncIsConnector(), icd.syncIsConnector()); ComponentProxy
		 * component = getComponentMap().get(mapName); if (component == null) {
		 * if (icd.isConnector()) { component = new
		 * DiagramConnectorProxy(componentName, this); } else { component = new
		 * ComponentProxy(componentName, this); } getComponentMap().put(mapName,
		 * component); } notifyObservers(COMPONENT_ADDED);
		 */
		ModificationJob job = new ModificationJob(IJobObject.ADD_NODE, theFile,
				getRealASTNode(), className, componentName, placement);
		ModelicaASTRegistryJobBucket.getInstance().addJob(job);
		return null;
	}

	@Override
	public void removeComponent(ComponentProxy component) {
		/*
		 * getASTNode().syncRemoveComponent(component.getComponentDecl());
		 * notifyObservers(COMPONENT_REMOVED);
		 */
		ModificationJob job = new ModificationJob(IJobObject.REMOVE_NODE,
				theFile, component.getRealASTNode());
		ModelicaASTRegistryJobBucket.getInstance().addJob(job);
	}

	@Override
	// TODO FIX SYNCH ASTREG
	public ConnectionProxy addConnection(ConnectorProxy source,
			ConnectorProxy target) {/*
									 * ConnectClause connectClause =
									 * getASTNode().syncAddConnection(
									 * source.buildDiagramName(),
									 * target.buildDiagramName());
									 * ConnectionProxy connection = new
									 * ConnectionProxy(source, target,
									 * connectClause, this);
									 * getConnectionMap().put(connectClause,
									 * connection); return connection;
									 */
		return null;
	}

	@Override
	// TODO FIX SYNCH ASTREG
	protected void addConnection(ConnectionProxy connection) {
		// getASTNode().syncAddConnection(connection.getConnectClause());
	}

	@Override
	// TODO FIX SYNCH ASTREG
	protected boolean removeConnection(ConnectionProxy connection) {
		/*
		 * getASTNode().syncRemoveConnection(
		 * getConnection(connection.getConnectClause()));
		 */
		return true;
	}

	public void saveModelicaFile(IProgressMonitor monitor) throws CoreException {
		synchronized (realInstClassDecl.state()) {
			StoredDefinition definition = realInstClassDecl.getDefinition();
			definition.getFile().setContents(
					new ByteArrayInputStream(definition.prettyPrintFormatted()
							.getBytes()), false, true, monitor);
		}
	}

	@Override
	// TODO FIX SYNCH ASTREG
	protected void setParameterValue(Stack<String> path, String value) {
		// instClassDecl.syncSetParameterValue(path, value);
		notifyObservers(FLUSH_CONTENTS);
	}

	@Override
	public boolean equals(Object obj) {
		if (obj instanceof ClassDiagramProxy) {
			ClassDiagramProxy other = (ClassDiagramProxy) obj;
			return instClassDecl.equals(other);
		}
		if (obj instanceof InstClassDecl) {
			InstClassDecl other = (InstClassDecl) obj;
			return instClassDecl.equals(other);
		}
		return false;
	}
}
