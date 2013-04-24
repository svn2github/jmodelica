package org.jmodelica.ide.graphical.proxy;

import java.util.ArrayList;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.ide.compiler.IJobObject;
import org.jmodelica.ide.compiler.ModelicaASTRegistryIDHandler;
import org.jmodelica.ide.compiler.ModelicaASTRegistryJobBucket;
import org.jmodelica.ide.compiler.ModificationJob;
import org.jmodelica.ide.graphical.proxy.cache.CachedInstClassDecl;
import org.jmodelica.ide.graphical.proxy.cache.CachedInstComponentDecl;

public class ClassDiagramProxy extends AbstractDiagramProxy {

	public static final Object COMPONENT_ADDED = new Object();
	public static final Object COMPONENT_REMOVED = new Object();
	public static final Object FLUSH_CONTENTS = new String("Flush contents now");

	private CachedInstClassDecl instClassDecl;
	private IFile theFile;

	public ClassDiagramProxy(IFile theFile, CachedInstClassDecl instClassDecl) {
		this.theFile = theFile;
		this.instClassDecl = instClassDecl;
	}

	@Override
	protected CachedInstClassDecl getCachedASTNode() {
		return instClassDecl;
	}

	public void setCachedInstClassDeclRoot(CachedInstClassDecl icdc) {
		this.instClassDecl = icdc;
	}

	@Override
	protected CachedInstComponentDecl getComponentDecl() {
		return null;
	}

	@Override
	protected CachedInstClassDecl getClassDecl() {
		return getCachedASTNode();
	}

	@Override
	public void addComponent(String className, String componentName,
			Placement placement) {
		System.out.println("Addcomp: classname=" + className);
		System.out.println("addmocp: compname=" + componentName);
		ModificationJob job = new ModificationJob(IJobObject.ADD_COMPONENT,
				theFile, getCachedASTNode().getClassASTPath(), className,
				componentName, placement);
		ModelicaASTRegistryJobBucket.getInstance().addJob(job);
	}

	@Override
	public void removeComponent(ComponentProxy component) {
		ArrayList<IJobObject> jobs = new ArrayList<IJobObject>();
		int changeSetId = ModelicaASTRegistryIDHandler.getInstance().getChangeSetID();
		for (ConnectionProxy connection : component.getConnections()) {
			ModificationJob job = new ModificationJob(
					IJobObject.REMOVE_CONNECTCLAUSE, theFile, connection
							.getConnectClause().getConnectClauseASTPath(),
					getCachedASTNode().getClassASTPath());
			job.setChangeSetId(changeSetId);
			jobs.add(job);
		}
		ModificationJob job = new ModificationJob(IJobObject.REMOVE_NODE,
				theFile, component.getComponentDecl().getComponentASTPath(),
				getCachedASTNode().getClassASTPath());
		job.setChangeSetId(changeSetId);
		jobs.add(job);
		for (IJobObject j : jobs)
			ModelicaASTRegistryJobBucket.getInstance().addJob(j);
	}

	@Override
	public void addConnection(String sourceDiagramName, String targetDiagramName) {
		ModificationJob job = new ModificationJob(IJobObject.ADD_CONNECTCLAUSE,
				theFile, sourceDiagramName, targetDiagramName,
				getCachedASTNode().getClassASTPath());
		ModelicaASTRegistryJobBucket.getInstance().addJob(job);
	}

	@Override
	protected void addConnection(ConnectionProxy connection) {
		addConnection(connection.getSource().buildDiagramName(), connection
				.getTarget().buildDiagramName());
	}

	@Override
	public void removeConnection(ConnectionProxy connection) {
		ModificationJob job = new ModificationJob(
				IJobObject.REMOVE_CONNECTCLAUSE, theFile, connection
						.getConnectClause().getConnectClauseASTPath(),
				getCachedASTNode().getClassASTPath());
		ModelicaASTRegistryJobBucket.getInstance().addJob(job);
	}

	@Override
	// TODO FIX SYNCH ASTREG
	protected void setParameterValue(Stack<String> path, String value) {
		// instClassDecl.syncSetParameterValue(path, value);
		// notifyObservers(FLUSH_CONTENTS);
	}

	@Override
	public boolean equals(Object obj) {
		if (obj instanceof ClassDiagramProxy) {
			ClassDiagramProxy other = (ClassDiagramProxy) obj;
			return instClassDecl.equals(other);
		}
		if (obj instanceof CachedInstClassDecl) {
			CachedInstClassDecl other = (CachedInstClassDecl) obj;
			return instClassDecl.equals(other);
		}
		return false;
	}

	@Override
	public void undoAddComponent() {
		ModificationJob job = new ModificationJob(IJobObject.UNDO_ADD_COMPONENT, null, null);
		ModelicaASTRegistryJobBucket.getInstance().addJob(job);
	}

	@Override
	public void undoRemoveComponent() {
		ModificationJob job = new ModificationJob(IJobObject.UNDO_REMOVE_NODE, null, null);
		ModelicaASTRegistryJobBucket.getInstance().addJob(job);
	}
}
