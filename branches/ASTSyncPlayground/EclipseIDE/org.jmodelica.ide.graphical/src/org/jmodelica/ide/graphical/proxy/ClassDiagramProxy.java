package org.jmodelica.ide.graphical.proxy;

import java.util.ArrayList;
import java.util.List;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTPathPart;
import org.jastadd.ed.core.model.ITaskObject;
import org.jmodelica.icons.Layer;
import org.jmodelica.icons.coord.Placement;
import org.jmodelica.icons.primitives.GraphicItem;
import org.jmodelica.ide.graphical.proxy.tasks.AddBendPointTask;
import org.jmodelica.ide.graphical.proxy.tasks.MoveBendPointTask;
import org.jmodelica.ide.graphical.proxy.tasks.MoveComponentTask;
import org.jmodelica.ide.graphical.proxy.tasks.RemoveBendPointTask;
import org.jmodelica.ide.graphical.proxy.tasks.ResizeComponentTask;
import org.jmodelica.ide.graphical.proxy.tasks.RotateComponentTask;
import org.jmodelica.ide.graphical.proxy.tasks.SetParameterValueTask;
import org.jmodelica.ide.sync.ASTRegTaskBucket;
import org.jmodelica.ide.sync.tasks.AddComponentTask;
import org.jmodelica.ide.sync.tasks.AddConnectionTask;
import org.jmodelica.ide.sync.tasks.RemoveComponentTask;
import org.jmodelica.ide.sync.tasks.RemoveConnectionTask;
import org.jmodelica.modelica.compiler.InstClassDecl;

public class ClassDiagramProxy extends AbstractDiagramProxy {

	public static final Object COMPONENT_ADDED = new Object();
	public static final Object COMPONENT_REMOVED = new Object();
	public static final Object FLUSH_CONTENTS = new String("Flush contents now");

	private IFile theFile;
	private Stack<IASTPathPart> classASTPath;
	private Layer cacheDiagramLayer;
	private String syncGetClassIconName;
	private List<ComponentProxy> components = new ArrayList<ComponentProxy>();
	private List<GraphicItem> graphics = new ArrayList<GraphicItem>();

	public ClassDiagramProxy(IFile theFile, InstClassDecl instClassDecl) {
		this.theFile = theFile;
		cacheDiagramLayer = instClassDecl.cacheDiagramLayer();
		syncGetClassIconName = instClassDecl.syncGetClassIconName();
		collectComponents(instClassDecl, components);
		collectGraphics(instClassDecl, graphics, inDiagram());
		constructConnections(instClassDecl);
	}

	@Override
	public List<ComponentProxy> getComponents() {
		return components;
	}

	@Override
	public List<GraphicItem> getGraphics() {
		return graphics;
	}

	protected Stack<IASTPathPart> getClassASTPath() {
		return classASTPath;
	}

	public void setClassASTPath(Stack<IASTPathPart> classASTPath) {
		this.classASTPath = classASTPath;
	}

	@Override
	protected Stack<IASTPathPart> getASTPath() {
		return null;
	}

	@Override
	public Layer getLayer() {
		return cacheDiagramLayer;
	}

	@Override
	public String syncGetClassIconName() {
		return syncGetClassIconName;
	}

	@Override
	public void addComponent(String className, String componentName,
			Placement placement, int undoActionId) {
		ITaskObject task = new AddComponentTask(theFile, getClassASTPath(),
				className, componentName, placement, undoActionId);
		ASTRegTaskBucket.getInstance().addTask(task);
	}

	@Override
	public void removeComponent(ComponentProxy component, int undoActionId) {
		ArrayList<ITaskObject> tasks = new ArrayList<ITaskObject>();
		for (ConnectionProxy connection : component.getConnections()) {
			ITaskObject connTask = new RemoveConnectionTask(theFile,
					getClassASTPath(), connection.getASTPath(), undoActionId);
			tasks.add(connTask);
		}
		ITaskObject task = new RemoveComponentTask(theFile,
				component.getASTPath(), getClassASTPath(), undoActionId);
		for (ITaskObject ito : tasks)
			ASTRegTaskBucket.getInstance().addTask(ito);
		ASTRegTaskBucket.getInstance().addTask(task);
	}

	@Override
	public void addConnection(String sourceDiagramName,
			String targetDiagramName, int undoActionId) {
		ITaskObject task = new AddConnectionTask(theFile, getClassASTPath(),
				sourceDiagramName, targetDiagramName, undoActionId);
		ASTRegTaskBucket.getInstance().addTask(task);
	}

	@Override
	protected void addConnection(ConnectionProxy connection, int undoActionId) {
		addConnection(connection.getSource().buildDiagramName(), connection
				.getTarget().buildDiagramName(), undoActionId);
	}

	@Override
	public void removeConnection(ConnectionProxy connection, int undoActionId) {
		ITaskObject task = new RemoveConnectionTask(theFile, getClassASTPath(),
				connection.getASTPath(), undoActionId);
		ASTRegTaskBucket.getInstance().addTask(task);
	}

	@Override
	public void moveComponent(ComponentProxy component, double x, double y) {
		ITaskObject job = new MoveComponentTask(theFile,
				component.getASTPath(), x, y);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	public void setParameterValue(Stack<IASTPathPart> componentASTPath,
			Stack<String> path, String value) {
		ITaskObject job = new SetParameterValueTask(theFile, componentASTPath,
				path, value);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	/**
	 * @Override public boolean equals(Object obj) { if (obj instanceof
	 *           ClassDiagramProxy) { ClassDiagramProxy other =
	 *           (ClassDiagramProxy) obj; return instClassDecl.equals(other); }
	 *           if (obj instanceof CachedInstClassDecl) { CachedInstClassDecl
	 *           other = (CachedInstClassDecl) obj; return
	 *           instClassDecl.equals(other); } return false; }
	 */
	@Override
	public void rotateComponent(ComponentProxy component, double angle) {
		ITaskObject job = new RotateComponentTask(theFile,
				component.getASTPath(), angle);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	public void resizeComponent(ComponentProxy component, double x, double y,
			double x2, double y2) {
		ITaskObject job = new ResizeComponentTask(theFile,
				component.getASTPath(), x, y, x2, y2);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	public void addBendPoint(ConnectionProxy connection, double x, double y,
			int index) {
		ITaskObject job = new AddBendPointTask(theFile,
				connection.getASTPath(), index, x, y);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	public void moveBendPoint(ConnectionProxy connection, double x, double y,
			int index) {
		ITaskObject job = new MoveBendPointTask(theFile,
				connection.getASTPath(), x, y, index);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	public void removeBendPoint(ConnectionProxy connection, int index) {
		ITaskObject job = new RemoveBendPointTask(theFile,
				connection.getASTPath(), index);
		ASTRegTaskBucket.getInstance().addTask(job);
	}
}