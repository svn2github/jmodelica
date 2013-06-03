package org.jmodelica.ide.sync;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.ASTChangeEvent;
import org.jastadd.ed.core.model.IASTPathPart;
import org.jastadd.ed.core.model.ITaskObject;
import org.jmodelica.ide.sync.tasks.AbstractModificationTask;
import org.jmodelica.ide.sync.tasks.AddComponentTask;
import org.jmodelica.ide.sync.tasks.AddConnectionTask;
import org.jmodelica.ide.sync.tasks.RemoveComponentTask;
import org.jmodelica.ide.sync.tasks.RemoveConnectionTask;
import org.jmodelica.ide.sync.tasks.UndoTask;
import org.jmodelica.modelica.compiler.Access;
import org.jmodelica.modelica.compiler.Comment;
import org.jmodelica.modelica.compiler.ComponentDecl;
import org.jmodelica.modelica.compiler.ConnectClause;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.InstProgramRoot;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class ASTRegModificationHandler {
	private ModelicaASTRegistry registry = ModelicaASTRegistry.getInstance();

	/**
	 * Default constructor. The {@link ASTRegModificationHandler} is
	 * instantiated by a job handler thread started by the
	 * {@link ASTRegTaskBucket}, and will perform one
	 * {@link AbstractModificationTask}.
	 */
	public ASTRegModificationHandler(AbstractModificationTask job) {
		switch (job.getJobType()) {
		case ITaskObject.REMOVE_COMPONENT:
			removeComponent((RemoveComponentTask) job);
			break;
		case ITaskObject.ADD_COMPONENT:
			addComponent((AddComponentTask) job);
			break;
		case ITaskObject.RENAME_NODE:
			renameNode(job);
			break;
		case ITaskObject.ADD_CONNECTCLAUSE:
			addConnection((AddConnectionTask) job);
			break;
		case ITaskObject.REMOVE_CONNECTCLAUSE:
			removeConnection((RemoveConnectionTask) job);
			break;
		case ITaskObject.UNDO_ADD:
			undoAddComponent((UndoTask) job);
			break;
		case ITaskObject.UNDO_REMOVE:
			undoRemoveNode((UndoTask) job);
			break;
		}
	}

	private void undoRemoveNode(UndoTask task) {
		ASTRegModificationUndoer.getInstance().undoLastNodeRemove(
				task.getUndoActionId());
	}

	private void undoAddComponent(UndoTask task) {
		ASTRegModificationUndoer.getInstance().undoLastNodeAdd(
				task.getUndoActionId());
	}

	private void removeConnection(RemoveConnectionTask task) {
		Stack<IASTPathPart> astPath = task.getClassASTPath();
		GlobalRootNode root = (GlobalRootNode) registry.doLookup(task.getFile()
				.getProject());
		SourceRoot sroot = root.getSourceRoot();
		synchronized (sroot.state()) {
			StoredDefinition def = registry.getLatestDef(task.getFile());
			FullClassDecl fcd = (FullClassDecl) registry.resolveSourceASTPath(
					def, astPath);
			if (fcd == null) {
				fcd = (FullClassDecl) registry.resolveSourceASTPath(def,
						astPath);
				if (fcd == null) {
					System.err.println("Could not resolve node ASTPath!");
					return;
				} else {
					astPath = registry.createDefPath(fcd);
				}
			}
			ConnectClause connectClause = (ConnectClause) registry
					.resolveSourceASTPath(def,
							task.getConnectionClauseASTPath());
			if (connectClause == null) {
				connectClause = (ConnectClause) registry.resolveSourceASTPath(
						def, task.getConnectionClauseASTPath());
				if (connectClause == null) {
					System.err.println("Could not resolve node ASTPath!");
					return;
				}
			}

			// For undo command of graph ed (queue add job containing component
			// info)
			AbstractModificationTask undo = new AddConnectionTask(
					task.getFile(), task.getClassASTPath(), connectClause
							.getConnector1().toString(), connectClause
							.getConnector2().toString(), task.getUndoActionId());
			ASTRegModificationUndoer.getInstance().addUndoRemoveJob(undo);
			// continue...

			fcd.removeEquation(connectClause);
			flushClassDeclCache(fcd);
			flushInstRoot(sroot);
		}
		ChangePropagationController.getInstance().handleNotifications(
				ASTChangeEvent.POST_ADDED, task.getFile(), astPath);
	}

	/**
	 * Adds an ConnectionClause Equation to its ClassDecl.
	 */
	private void addConnection(AddConnectionTask task) {
		Stack<IASTPathPart> astPath = task.getClassASTPath();
		GlobalRootNode root = (GlobalRootNode) registry.doLookup(task.getFile()
				.getProject());
		SourceRoot sroot = root.getSourceRoot();
		synchronized (sroot.state()) {
			StoredDefinition def = registry.getLatestDef(task.getFile());
			FullClassDecl fcd = (FullClassDecl) registry.resolveSourceASTPath(
					def, astPath);
			if (fcd == null) {
				fcd = (FullClassDecl) registry.resolveSourceASTPath(def,
						astPath);
				if (fcd == null) {
					System.err.println("Could not resolve node ASTPath!");
					return;
				} else {
					astPath = registry.createDefPath(fcd);
				}
			}

			ConnectClause connectClause = new ConnectClause();
			connectClause.setComment(new Comment());
			connectClause.setConnector1(Access.fromClassName(task
					.getSourceDiagramName()));
			connectClause.setConnector2(Access.fromClassName(task
					.getTargetDiagramName()));
			fcd.addNewEquation(connectClause);

			// For undo command of graph ed (queue add job containing component
			// info)
			AbstractModificationTask undo = new RemoveConnectionTask(
					task.getFile(), task.getClassASTPath(), ModelicaASTRegistry
							.getInstance().createDefPath(connectClause),
					task.getUndoActionId());
			ASTRegModificationUndoer.getInstance().addUndoAddJob(undo);
			// continue...

			flushClassDeclCache(fcd);
			flushInstRoot(sroot);
		}
		ChangePropagationController.getInstance().handleNotifications(
				ASTChangeEvent.POST_ADDED, task.getFile(), astPath);
	}

	/**
	 * Rename the given node.
	 */
	private void renameNode(AbstractModificationTask task) {
		/**
		 * long time = System.currentTimeMillis(); GlobalRootNode root =
		 * (GlobalRootNode) registry.doLookup(file .getProject()); SourceRoot
		 * sroot = root.getSourceRoot(); synchronized (sroot.state()) {
		 * //StoredDefinition def =(StoredDefinition)
		 * sroot.getProgram().lookupChildAST(job.getFile().getName());
		 * //ASTNode<?> srcNode = registry.resolveSourceASTPath(file, //
		 * renameNodePath, sroot); //if (srcNode == null) { // srcNode =
		 * (FullClassDecl) registry.recoveryResolve(file, renameNodePath); if
		 * (srcNode == null) {
		 * System.err.println("Could not resolve node ASTPath!"); return; } else
		 * { renameNodePath = registry.createPath(srcNode); } }
		 * 
		 * if (srcNode instanceof FullClassDecl) { FullClassDecl decl =
		 * (FullClassDecl) srcNode; decl.getName().setID(newName); } else if
		 * (srcNode instanceof ComponentDecl) { ComponentDecl compdecl =
		 * (ComponentDecl) srcNode; compdecl.getName().setID(newName); }
		 * ChangePropagationController.getInstance().handleNotifications(
		 * ASTChangeEvent.POST_RENAME, file, renameNodePath); } System.out
		 * .println(
		 * "ModelicaAstReg: RenameJob+handling/starting notification threads took: "
		 * + (System.currentTimeMillis() - time) + "ms");
		 */
	}

	/**
	 * Add a ComponentDecl to a ClassDecl.
	 */
	private void addComponent(AddComponentTask task) {
		IFile file = task.getFile();
		GlobalRootNode root = (GlobalRootNode) registry.doLookup(file
				.getProject());
		SourceRoot sroot = root.getSourceRoot();
		synchronized (sroot.state()) {
			StoredDefinition def = registry.getLatestDef(task.getFile());
			FullClassDecl fcd = (FullClassDecl) registry.resolveSourceASTPath(
					def, task.getClassASTPath());
			ComponentDecl added = fcd.addComponent(task.getClassName(),
					task.getComponentName(), task.getPlacement());

			// For undo command of graph ed (queue add job containing component
			// info)
			AbstractModificationTask undo = new RemoveComponentTask(file,
					ModelicaASTRegistry.getInstance().createDefPath(added),
					task.getClassASTPath(), task.getUndoActionId());
			ASTRegModificationUndoer.getInstance().addUndoAddJob(undo);
			// continue...

			flushInstRoot(sroot);
			ChangePropagationController.getInstance().handleNotifications(
					ASTChangeEvent.POST_ADDED, file, task.getClassASTPath());
		}
	}

	private void flushInstRoot(SourceRoot sroot) {
		InstProgramRoot iRoot = sroot.getProgram().getInstProgramRoot();
		iRoot.flushCache();
		iRoot.classes();
		iRoot.components();
	}

	/**
	 * Removes a ComponentDecl from its ClassDecl.
	 */
	private void removeComponent(RemoveComponentTask task) {
		GlobalRootNode root = (GlobalRootNode) registry.doLookup(task.getFile()
				.getProject());
		SourceRoot sroot = root.getSourceRoot();
		synchronized (sroot.state()) {
			StoredDefinition def = ModelicaASTRegistry.getInstance()
					.getLatestDef(task.getFile());
			FullClassDecl fcd = (FullClassDecl) registry.resolveSourceASTPath(
					def, task.getClassASTPath());
			ComponentDecl cd = (ComponentDecl) registry.resolveSourceASTPath(
					def, task.getComponentASTPath());

			// For undo command of graph ed (queue add job containing component
			// info)
			AbstractModificationTask undo = new AddComponentTask(
					task.getFile(), task.getClassASTPath(), cd.getClassName()
							.toString(), cd.getName().getID(),
					cd.syncGetPlacement(), task.getUndoActionId());
			ASTRegModificationUndoer.getInstance().addUndoRemoveJob(undo);
			// continue...

			fcd.removeComponentDecl(cd);
			flushClassDeclCache(fcd);
			flushInstRoot(sroot);

			ChangePropagationController.getInstance().handleNotifications(
					ASTChangeEvent.POST_REMOVE, task.getFile(),
					task.getClassASTPath());
		}
	}

	private void flushClassDeclCache(FullClassDecl fcd) {
		fcd.flushCache();
		fcd.components();
		fcd.classes();
	}
}