package org.jmodelica.ide.graphical.proxy;

import java.io.ByteArrayInputStream;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.ide.compiler.JobObject;
import org.jmodelica.ide.compiler.ModelicaASTRegistryJobBucket;
import org.jmodelica.modelica.compiler.ConnectClause;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstComponentDecl;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class ClassDiagramProxy extends AbstractDiagramProxy {

	public static final Object COMPONENT_ADDED = new Object();
	public static final Object COMPONENT_REMOVED = new Object();
	public static final Object FLUSH_CONTENTS = new String("Flush contents now");

	private InstClassDecl instClassDecl;
	private IFile theFile;

	public ClassDiagramProxy(IFile theFile, InstClassDecl instClassDecl) {
		this.theFile = theFile;
		this.instClassDecl = instClassDecl;
	}

	@Override
	protected InstClassDecl getASTNode() {
		return instClassDecl;
	}

	public void setInstClassDecl(InstClassDecl instClassDecl) {
		this.instClassDecl = instClassDecl;
	}

	@Override
	protected InstComponentDecl getComponentDecl() {
		return null;
	}

	@Override
	protected InstClassDecl getClassDecl() {
		return getASTNode();
	}

	public String getDefinitionKey() {
		synchronized (instClassDecl.state()) {
			return instClassDecl.getDefinition().lookupKey();
		}
	}

	@Override
	public ComponentProxy addComponent(String className, String componentName,
			Placement placement) {
		String mapName;
		System.out.println("GRAPHICAL: adding node to component "+getASTNode().getNodeName());
		InstComponentDecl icd = getASTNode().syncAddComponent(className,
				componentName, placement);
		mapName = buildMapName(icd.syncQualifiedName(), icd.syncIsConnector(),
				icd.syncIsConnector());
		ComponentProxy component = getComponentMap().get(mapName);
		if (component == null) {
			if (icd.isConnector()) {
				component = new DiagramConnectorProxy(componentName, this);
			} else {
				component = new ComponentProxy(componentName, this);
			}
			getComponentMap().put(mapName, component);
		}
		notifyObservers(COMPONENT_ADDED);
		JobObject job = new JobObject(JobObject.ADD_NODE, theFile,
				icd);
		ModelicaASTRegistryJobBucket.getInstance().addJob(job);
		return component;
	}

	@Override
	public void removeComponent(ComponentProxy component) {
		getASTNode().syncRemoveComponent(component.getComponentDecl());
		notifyObservers(COMPONENT_REMOVED);
		JobObject job = new JobObject(JobObject.REMOVE_INSTNODE, theFile,
				component.getASTNode());
		ModelicaASTRegistryJobBucket.getInstance().addJob(job);
	}

	@Override
	public ConnectionProxy addConnection(ConnectorProxy source,
			ConnectorProxy target) {
		ConnectClause connectClause = getASTNode().syncAddConnection(
				source.buildDiagramName(), target.buildDiagramName());
		ConnectionProxy connection = new ConnectionProxy(source, target,
				connectClause, this);
		getConnectionMap().put(connectClause, connection);
		return connection;
	}

	@Override
	protected void addConnection(ConnectionProxy connection) {
		getASTNode().syncAddConnection(connection.getConnectClause());
	}

	@Override
	protected boolean removeConnection(ConnectionProxy connection) {
		getASTNode().syncRemoveConnection(
				getConnection(connection.getConnectClause()));
		return true;
	}

	public void saveModelicaFile(IProgressMonitor monitor) throws CoreException {
		synchronized (instClassDecl.state()) {
			StoredDefinition definition = instClassDecl.getDefinition();
			definition.getFile().setContents(
					new ByteArrayInputStream(definition.prettyPrintFormatted()
							.getBytes()), false, true, monitor);
		}
	}

	@Override
	protected void setParameterValue(Stack<String> path, String value) {
		instClassDecl.syncSetParameterValue(path, value);
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
