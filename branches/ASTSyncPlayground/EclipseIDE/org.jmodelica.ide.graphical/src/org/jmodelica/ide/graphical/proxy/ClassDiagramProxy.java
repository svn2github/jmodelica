package org.jmodelica.ide.graphical.proxy;

import java.util.ArrayList;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.ide.graphical.proxy.cache.CachedInstClassDecl;
import org.jmodelica.ide.graphical.proxy.cache.CachedInstComponentDecl;
import org.jmodelica.ide.graphical.proxy.cache.tasks.AddBendPointTask;
import org.jmodelica.ide.graphical.proxy.cache.tasks.MoveBendPointTask;
import org.jmodelica.ide.graphical.proxy.cache.tasks.MoveComponentTask;
import org.jmodelica.ide.graphical.proxy.cache.tasks.RemoveBendPointTask;
import org.jmodelica.ide.graphical.proxy.cache.tasks.ResizeComponentTask;
import org.jmodelica.ide.graphical.proxy.cache.tasks.RotateComponentTask;
import org.jmodelica.ide.graphical.proxy.cache.tasks.SetParameterValueTask;
import org.jmodelica.ide.sync.ASTRegTaskBucket;
import org.jmodelica.ide.sync.tasks.AddComponentTask;
import org.jmodelica.ide.sync.tasks.AddConnectionTask;
import org.jmodelica.ide.sync.tasks.ITaskObject;
import org.jmodelica.ide.sync.tasks.RemoveComponentTask;
import org.jmodelica.ide.sync.tasks.RemoveConnectionTask;

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
			Placement placement, int undoActionId) {
		ITaskObject task = new AddComponentTask(theFile, getCachedASTNode()
				.getClassASTPath(), className, componentName, placement,
				undoActionId);
		ASTRegTaskBucket.getInstance().addTask(task);
	}

	@Override
	public void removeComponent(ComponentProxy component, int undoActionId) {
		ArrayList<ITaskObject> tasks = new ArrayList<ITaskObject>();
		for (ConnectionProxy connection : component.getConnections()) {
			System.err.println("bolololo");
			ITaskObject connTask = new RemoveConnectionTask(theFile,
					getCachedASTNode().getClassASTPath(), connection
							.getConnectClause().getConnectClauseASTPath(),
					undoActionId);
			tasks.add(connTask);
			/**
			 * for (ConnectionProxy cp :
			 * connection.getSource().getConnections()) {
			 * System.err.println("yoolololo"); if
			 * (cp.getTarget().equals(component) ||
			 * cp.getSource().equals(component)) { ModificationTask job2 = new
			 * ModificationTask( ITaskObject.REMOVE_CONNECTCLAUSE, theFile, cp
			 * .getConnectClause() .getConnectClauseASTPath(),
			 * getCachedASTNode().getClassASTPath());
			 * job2.setPrio(ITaskObject.PRIORITY_HIGHEST);
			 * job2.setUndoActionId(undoActionId); tasks.add(job2); } }
			 */
		}
		ITaskObject task = new RemoveComponentTask(theFile, component
				.getComponentDecl().getComponentASTPath(), getCachedASTNode()
				.getClassASTPath(), undoActionId);
		tasks.add(task);
		for (ITaskObject ito : tasks)
			ASTRegTaskBucket.getInstance().addTask(ito);
	}

	@Override
	public void addConnection(String sourceDiagramName,
			String targetDiagramName, int undoActionId) {
		ITaskObject task = new AddConnectionTask(theFile, getCachedASTNode()
				.getClassASTPath(), sourceDiagramName, targetDiagramName,
				undoActionId);
		ASTRegTaskBucket.getInstance().addTask(task);
	}

	@Override
	protected void addConnection(ConnectionProxy connection, int undoActionId) {
		addConnection(connection.getSource().buildDiagramName(), connection
				.getTarget().buildDiagramName(), undoActionId);
	}

	@Override
	public void removeConnection(ConnectionProxy connection, int undoActionId) {
		ITaskObject task = new RemoveConnectionTask(theFile, getCachedASTNode()
				.getClassASTPath(), connection.getConnectClause()
				.getConnectClauseASTPath(), undoActionId);
		ASTRegTaskBucket.getInstance().addTask(task);
	}

	@Override
	public void moveComponent(ComponentProxy component, double x, double y) {
		ITaskObject job = new MoveComponentTask(theFile,
				component.getComponentDecl().getComponentASTPath(), x, y);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	protected void setParameterValue(CachedInstComponentDecl comp,
			Stack<String> path, String value) {
		System.err.println("PARAMTER  val:" + value + " comp:"
				+ comp.syncQualifiedName() + " astpath:"
				+ comp.getComponentASTPath() + " path:" + path);
		ITaskObject job = new SetParameterValueTask(
				theFile, comp.getComponentASTPath(), path, value);
		ASTRegTaskBucket.getInstance().addTask(job);
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
	public void rotateComponent(ComponentProxy component, double angle) {
		ITaskObject job = new RotateComponentTask(
				theFile, component.getComponentDecl().getComponentASTPath(),
				angle);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	public void resizeComponent(ComponentProxy component, double x, double y,
			double x2, double y2) {
		ITaskObject job = new ResizeComponentTask(
				theFile, component.getComponentDecl().getComponentASTPath(), x,
				y, x2, y2);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	public void addBendPoint(ConnectionProxy connection, double x, double y,
			int index) {
		ITaskObject job = new AddBendPointTask(theFile,
				connection.getConnectClause().getConnectClauseASTPath(), index,
				x, y);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	public void moveBendPoint(ConnectionProxy connection, double x, double y,
			int index) {
		ITaskObject job = new MoveBendPointTask(theFile,
				connection.getConnectClause().getConnectClauseASTPath(), x, y,
				index);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	public void removeBendPoint(ConnectionProxy connection, int index) {
		ITaskObject job = new RemoveBendPointTask(
				theFile, connection.getConnectClause()
						.getConnectClauseASTPath(), index);
		ASTRegTaskBucket.getInstance().addTask(job);
	}
}
