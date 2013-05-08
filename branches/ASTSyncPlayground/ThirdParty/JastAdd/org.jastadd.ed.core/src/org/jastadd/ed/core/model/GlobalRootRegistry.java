package org.jastadd.ed.core.model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.jobs.ILock;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.swt.widgets.Display;
import org.jastadd.ed.core.ICompiler;
import org.jastadd.ed.core.model.node.ILocalRootNode;
import org.jastadd.ed.core.model.node.IGlobalRootNode;

/**
 * This class may be used as is or be extended via a subclasses. In either case
 * it should be used as a singleton for one or several plug-ins.
 * 
 * @author emma
 * 
 */
public abstract class GlobalRootRegistry implements IGlobalRootRegistry {

	// TODO: Handle single external files

	protected Map<IProject, IGlobalRootNode> fProjectASTMap = new HashMap<IProject, IGlobalRootNode>();
	protected Map<IProject, ILock> fProjectLockMap = new HashMap<IProject, ILock>();
	protected List<IASTChangeListener> fListereList = new ArrayList<IASTChangeListener>();
	protected ILock fListenerLock = Job.getJobManager().newLock();

	/**
	 * Create the compiler for this Registry.
	 * 
	 * @return
	 */
	protected abstract ICompiler createCompiler();

	@Override
	public ILock getGlobalLock(IProject project) {
		if (fProjectLockMap.containsKey(project)) {
			return fProjectLockMap.get(project);
		}
		ILock lock = Job.getJobManager().newLock();
		fProjectLockMap.put(project, lock);
		return lock;
	}

	/**
	 * Updates the AST corresponding to the given project. This method update
	 * will try to update as few nodes as possible. The old node entry will be
	 * traversed and compared to the new node.
	 * 
	 * @param project
	 *            The projects which corresponding AST should be updated
	 * @param newNode
	 *            The node with new information
	 * @return true if an AST was found and updated, or false if not
	 */
	public boolean doUpdate(IProject project, IGlobalRootNode newNode) {
		// printProjAndFiles();
		if (project == null || newNode == null) {
			return false;
		}
		updateProject(project, newNode);
		return true;
	}

	/**
	 * Updates the AST corresponding to the given file. This method will try to
	 * update as little as possible via a comparative traversal of the old and
	 * the new node.
	 * 
	 * @param file
	 *            The file for which the corresponding AST should be updated
	 * @param newNode
	 *            The node with new information
	 * @return true if a matching AST was found and updated, or false if not
	 */
	public boolean doUpdate(IFile file, ILocalRootNode newNode) {
		if (file == null || newNode == null) {
			return false;
		}
		return updateFile(file, newNode);
	}

	/**
	 * Discards the AST corresponding to the given project
	 * 
	 * @param project
	 *            The project for which the corresponding AST should be
	 *            discarded
	 * @return true if an AST was found and discarded, or false if no AST was
	 *         found
	 */
	public boolean doDiscard(IProject project) {
		if (project == null)
			return false;
		return discardProject(project);
	}

	/**
	 * Discards the AST corresponding to a given file
	 * 
	 * @param file
	 *            The file for which the corresponding AST should be discarded
	 * @return true if file was found and discarded, or false if no file was
	 *         found
	 */
	public boolean doDiscard(IFile file) {
		if (file == null)
			return false;
		return discardFile(file);
	}

	/**
	 * This method will look up the corresponding AST of the given project
	 * 
	 * @param project
	 *            The project to use as key
	 * @return The AST or null if there was no entry for the project
	 */
	public IGlobalRootNode doLookup(IProject project) {
		if (project == null)
			return null;
		return lookupProject(project);
	}

	/**
	 * This method will look up the AST corresponding to the given file.
	 * 
	 * @param file
	 *            The file to use as key.
	 * @return The AST or null if no entry was found
	 */
	public ILocalRootNode[] doLookup(IFile file) {
		if (file == null)
			return null;
		if (lookupFile(file).length == 0) {
			System.out.println("Lookup of file: " + file.getName()
					+ " returned 0 ast results...");
			compileFile(file);
		}
		return lookupFile(file);
	}

	/**
	 * Adds a listener.
	 * 
	 * @param listener
	 *            The listener to add
	 */
	public void addListener(IASTChangeListener listener) {
		synchronized (GlobalRootRegistry.class) {
			fListereList.add(listener);
		}
	}

	/**
	 * Removes a listener.
	 * 
	 * @param listener
	 *            The listener to remove
	 */
	public void removeListener(IASTChangeListener listener) {
		synchronized (GlobalRootRegistry.class) {
			fListereList.remove(listener);
		}
	}

	/**
	 * Looks up a file node
	 * 
	 * @param file
	 *            The node to look up
	 * @return The file node, or null if no entry was found
	 */
	/*
	 * Looks up the project for the node and asks its corresponding project node
	 * (global root node) for a matching file node (local root node).
	 */
	protected ILocalRootNode[] lookupFile(IFile file) {
		List<ILocalRootNode> nodeList = new ArrayList<ILocalRootNode>();
		IProject project = file.getProject();
		ILock lock = getGlobalLock(project);
		try {
			lock.acquire();
			for (IProject p : fProjectASTMap.keySet()) {
				if (project.equals(p)) {
					IGlobalRootNode projectNode = fProjectASTMap.get(project);
					nodeList = projectNode.lookupFileNode(file);
					break;
				}
			}
		} finally {
			lock.release();
		}
		ILocalRootNode[] result = new ILocalRootNode[nodeList.size()];
		int i = 0;
		for (ILocalRootNode node : nodeList)
			result[i++] = node;
		return result;
	}

	/**
	 * Looks up a project node
	 * 
	 * @param project
	 *            The project to look up
	 * @return The project node, or null if no entry was found
	 */
	protected IGlobalRootNode lookupProject(IProject project) {
		IGlobalRootNode projectNode = null;
		// TODO: Lock?
		if (fProjectASTMap.containsKey(project)) {
			projectNode = fProjectASTMap.get(project);
		} else {
			System.out.println("Compiler compiling project: "
					+ project.getName());
			projectNode = createCompiler().compile(project);
			doUpdate(project, projectNode);
		}
		return projectNode;
	}

	/**
	 * Discards a file entry
	 * 
	 * @param file
	 *            The file to discard
	 * @return true if OK, or false if no enclosing project node was found
	 */
	protected boolean discardFile(IFile file) {
		boolean result = false;
		IProject project = file.getProject();
		ILock lock = getGlobalLock(project);
		try {
			lock.acquire();
			for (IProject p : fProjectASTMap.keySet()) {
				if (project.equals(p)) {
					IGlobalRootNode projectNode = fProjectASTMap.get(file
							.getProject());
					// projectNode.fullFlush();
					List<ILocalRootNode> nodeList = new ArrayList<ILocalRootNode>();
					nodeList = projectNode.lookupFileNode(file);
					List<ASTDelta> deltaList = new ArrayList<ASTDelta>();
					for (ILocalRootNode fileNode : nodeList) {
						fileNode.discardFromTree();
						ASTDelta delta = new ASTDelta(fileNode,
								new IASTDelta[] {});
						delta.setStatus(IASTDelta.REMOVED);
						deltaList.add(delta);
					}
					ASTDelta projectDelta = new ASTDelta(projectNode,
							deltaList.toArray(new IASTDelta[] {}));
					projectDelta.setStatus(IASTDelta.CHANGED
							| IASTDelta.CHILD_CHANGED);
					ASTChangeEvent evt = new ASTChangeEvent(
							ASTChangeEvent.POST_REMOVE,
							ASTChangeEvent.FILE_LEVEL, projectNode, null,
							projectDelta);// TODO fix null
					notifyListeners(evt);
					result = true;
				}
			}
		} finally {
			lock.release();
		}
		return result;
	}

	/**
	 * Discards a project entry
	 * 
	 * @param project
	 *            The project to discard
	 * @return true if ok, or false if no project entry was found
	 */
	protected boolean discardProject(IProject project) {
		boolean result = false;
		// TODO: Lock?
		if (fProjectASTMap.containsKey(project)) {
			IGlobalRootNode projectNode = fProjectASTMap.get(project);
			// projectNode.fullFlush();
			fProjectASTMap.remove(project);
			ILocalRootNode[] fileNode = projectNode.lookupAllFileNodes();
			IASTDelta[] childDelta = new IASTDelta[fileNode.length];
			for (int i = 0; i < fileNode.length; i++) {
				fileNode[i].discardFromTree();
				ASTDelta delta = new ASTDelta(fileNode[i], new IASTDelta[] {});
				delta.setStatus(IASTDelta.REMOVED);
			}
			ASTDelta projectDelta = new ASTDelta(projectNode, childDelta);
			projectDelta.setStatus(IASTDelta.REMOVED);
			ASTChangeEvent evt = new ASTChangeEvent(ASTChangeEvent.POST_REMOVE,
					ASTChangeEvent.PROJECT_LEVEL, projectNode, null,
					projectDelta);// TODO fix null
			notifyListeners(evt);
			result = true;
		}
		return result;
	}

	/**
	 * Updates a file node with the given node
	 * 
	 * @param file
	 *            The file to update
	 * @param newNode
	 *            The node to update with
	 * @return true if ok, or false if no enclosing project node was found
	 */
	protected boolean updateFile(IFile file, ILocalRootNode newNode) {

		boolean result = false;
		ILock lock = getGlobalLock(file.getProject());
		try {
			lock.acquire();
			IProject project = file.getProject();
			for (IProject p : fProjectASTMap.keySet()) {
				if (project.equals(p)) {
					IGlobalRootNode projectNode = fProjectASTMap.get(file
							.getProject());
					projectNode.addFileNode(newNode);
					ASTDelta delta = new ASTDelta(newNode, new IASTDelta[] {});
					delta.setStatus(IASTDelta.CHANGED | IASTDelta.CONTENT);
					IASTDelta[] childDelta = new IASTDelta[] { delta };
					ASTDelta projectDelta = new ASTDelta(projectNode,
							childDelta);
					projectDelta.setStatus(IASTDelta.CHANGED
							| IASTDelta.CHILD_CHANGED);
					ASTChangeEvent evt = new ASTChangeEvent(
							ASTChangeEvent.POST_UPDATE,
							ASTChangeEvent.PROJECT_LEVEL, projectNode, null,
							projectDelta);// TODO
											// fix
											// null
					notifyListeners(evt);
					result = true;
					break;
				}
			}
		} finally {
			lock.release();
		}
		return result;
	}

	/**
	 * Updates a project node with the given new node
	 * 
	 * @param project
	 *            The project to update
	 * @param newNode
	 *            The new node to update with
	 */
	protected void updateProject(IProject project, IGlobalRootNode newNode) {

		if (!fProjectASTMap.containsKey(project)) {
			registerProject(project, newNode);
		} else {
			ILock lock = getGlobalLock(project);
			try {
				lock.acquire();
				IGlobalRootNode projectNode = fProjectASTMap.get(project);
				// projectNode.fullFlush();
				ILocalRootNode[] newFileNode = newNode.lookupAllFileNodes();
				ILocalRootNode[] oldFileNode = projectNode.lookupAllFileNodes();
				IASTDelta[] childDelta = compareFileNodes(projectNode,
						oldFileNode, newFileNode);
				ASTDelta projectDelta = new ASTDelta(projectNode, childDelta);
				fProjectASTMap.put(project, newNode);
				ASTChangeEvent evt = new ASTChangeEvent(
						ASTChangeEvent.POST_UPDATE,
						ASTChangeEvent.PROJECT_LEVEL, projectNode, null,
						projectDelta);// TODO fix null
				notifyListeners(evt);
			} finally {
				lock.release();
			}
		}

	}

	/**
	 * This is a helper method to the protected update project method
	 * 
	 * @see updateProject !!This method is called within a locked context!!
	 * 
	 *      This method will add new file nodes, note removed file nodes and
	 *      update changed file nodes.
	 * 
	 * @param projectNode
	 *            The project node for which file will be compared
	 * @param oldFileNode
	 *            The old set of file nodes
	 * @param newFileNode
	 *            The new set of file nodes
	 * @return The delta after comparing file sets
	 */
	protected IASTDelta[] compareFileNodes(IGlobalRootNode projectNode,
			ILocalRootNode[] oldFileNode, ILocalRootNode[] newFileNode) {
		List<ASTDelta> deltaList = new ArrayList<ASTDelta>();
		for (int i = 0; i < newFileNode.length; i++) {
			List<ILocalRootNode> nodeList = projectNode
					.lookupFileNode(newFileNode[i].getFile());
			boolean foundCorresponding = false;
			for (ILocalRootNode node : nodeList) {
				if (node.correspondsTo(newFileNode[i])) {
					foundCorresponding = true;
					// Not equal to previous AST -- update node
					if (node.shouldBeUpdatedWith(newFileNode[i])) {
						node.updateWith(newFileNode[i]);
						ASTDelta delta = new ASTDelta(newFileNode[i],
								new IASTDelta[] {});
						delta.setStatus(IASTDelta.CHANGED | IASTDelta.CONTENT);
						deltaList.add(delta);
					}
				}
			}
			// No previous file AST -- add node
			if (!foundCorresponding) {
				projectNode.addFileNode(newFileNode[i]);
				ASTDelta delta = new ASTDelta(newFileNode[i],
						new IASTDelta[] {});
				delta.setStatus(IASTDelta.ADDED);
				deltaList.add(delta);
			}
		}
		// Check for removal -- oldNodes with no corresponding new file node
		for (int i = 0; i < oldFileNode.length; i++) {
			boolean foundCorresponding = false;
			for (int k = 0; k < newFileNode.length; k++) {
				if (oldFileNode[i].correspondsTo(newFileNode[k])) {
					foundCorresponding = true;
				}
			}
			if (!foundCorresponding) {
				oldFileNode[i].discardFromTree();
				ASTDelta delta = new ASTDelta(oldFileNode[i],
						new IASTDelta[] {});
				delta.setStatus(IASTDelta.REMOVED);
			}
		}
		return deltaList.toArray(new ASTDelta[] {});
	}

	/**
	 * Register a new project. This method will request and release the lock.
	 * 
	 * @param project
	 *            The project to register
	 * @param newNode
	 *            The node of the project
	 */
	protected void registerProject(IProject project, IGlobalRootNode newNode) {

		// TODO: Lock?
		fProjectASTMap.put(project, newNode);
		/**
		 * ILocalRootNode[] fileNode = newNode.lookupAllFileNodes(); ASTDelta[]
		 * fileDelta = new ASTDelta[fileNode.length]; for (int i = 0; i <
		 * fileNode.length; i++) { fileDelta[i] = new ASTDelta(fileNode[i], new
		 * IASTDelta[] {}); fileDelta[i].setStatus(IASTDelta.ADDED); } ASTDelta
		 * projectDelta = new ASTDelta(newNode, fileDelta);
		 * projectDelta.setStatus(IASTDelta.ADDED);
		 */
		ASTChangeEvent evt = new ASTChangeEvent(ASTChangeEvent.POST_ADDED,
				ASTChangeEvent.PROJECT_LEVEL, newNode, null, null);// projectDelta);
																	// TODO fix
																	// null

		notifyListeners(evt);
	}

	/**
	 * Notify listeners. This might update SWT components which means we need to
	 * notify using Display.syncExec(Runnable).
	 * 
	 * @param evt
	 *            The AST change event
	 */
	protected void notifyListeners(final IASTChangeEvent evt) {
		final IASTChangeListener[] l = new IASTChangeListener[fListereList
				.size()];
		fListenerLock.acquire();
		fListereList.toArray(l);
		fListenerLock.release();
		for (int i = 0; i < l.length; i++) {
			final int j = i;
			Display.getDefault().asyncExec(new Runnable() {
				public void run() {
					l[j].astChanged(evt);
				}
			});

		}
	}

	public void compileFile(IFile file) {
		ICompiler compiler = createCompiler();
		if (compiler.canCompile(file)) {
			if (!fProjectASTMap.containsKey(file.getProject())) {
				lookupProject(file.getProject());
			} else {
				System.out
						.println("Compiler compiling file: " + file.getName());
				ILocalRootNode fileNode = compiler.compile(file);
				doUpdate(file, fileNode);
			}
		} else {
			System.out.println("Compiler could NOT compile file: "
					+ file.getName());
		}
	}
}
