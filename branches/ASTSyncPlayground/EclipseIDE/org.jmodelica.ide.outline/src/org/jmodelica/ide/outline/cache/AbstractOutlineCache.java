package org.jmodelica.ide.outline.cache;

import java.util.ArrayList;
import org.eclipse.core.resources.IFile;
import org.eclipse.swt.widgets.Display;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.helpers.ICachedOutlineNode;
import org.jmodelica.ide.helpers.IOutlineCache;
import org.jmodelica.ide.outline.OutlineUpdateWorker;
import org.jmodelica.ide.sync.CachedASTNode;
import org.jmodelica.ide.sync.ChangePropagationController;
import org.jmodelica.ide.sync.ListenerObject;
import org.jmodelica.ide.sync.UniqueIDGenerator;
import org.jmodelica.ide.sync.tasks.ITaskObject;

public abstract class AbstractOutlineCache implements IOutlineCache,
		IASTChangeListener {
	protected IASTChangeListener myOutline;
	protected IFile myFile;
	protected CachedASTNode myCache;
	private ArrayList<EventCachedChildren> childrenUpdates = new ArrayList<EventCachedChildren>();
	private ArrayList<EventCachedInitial> rootUpdates = new ArrayList<EventCachedInitial>();
	protected int listenerID;

	public AbstractOutlineCache(IASTChangeListener outline) {
		myOutline = outline;
		this.listenerID = UniqueIDGenerator.getInstance().getListenerID();
	}

	public int getListenerID() {
		return listenerID;
	}

	public void setFile(IFile file, boolean registerASTListener) {
		if (file != null) {
			myFile = file;
			createInitialCache();
			if (registerASTListener) {
				ListenerObject listObj = new ListenerObject(this,
						IASTChangeListener.OUTLINE_LISTENER, listenerID);
				ChangePropagationController.getInstance().addListener(listObj,
						file, null);
			}
		}
	}

	protected void handleCachedChildrenEvent() {
		if (!childrenUpdates.isEmpty()) {
			EventCachedChildren event = childrenUpdates.remove(0);
			OutlineUpdateWorker.ChildrenTask task = event.getTask();
			ArrayList<ICachedOutlineNode> children = event.getCachedChildren();
			if (task.node instanceof ICachedOutlineNode)
				((ICachedOutlineNode) task.node).setOutlineChildren(children);
			OutlineUpdateWorker.addChildrenTask(task);
		}
	}

	protected void handleCachedInitialEvent() {
		if (!rootUpdates.isEmpty()) {
			EventCachedInitial event = rootUpdates.remove(0);
			myCache = event.getCachedRoot();
			myOutline.astChanged(null);
		}
	}

	public void dispose() {
		ChangePropagationController.getInstance().removeListener(this, myFile,
				null);
	}

	/**
	 * We don't want several notifications at the same time, nor concurrency
	 * problems with the childrenUpdates vector, so we synchronize (on whole
	 * class). Spawned synxExec threads started by this method will run
	 * synchronized within GUI thread, so no need for further synchronization...
	 */
	@Override
	public synchronized void astChanged(IASTChangeEvent e) {
		if (e instanceof EventCachedChildren) {
			childrenUpdates.add((EventCachedChildren) e);
			Display.getDefault().syncExec(new Runnable() {
				public void run() {
					handleCachedChildrenEvent();
				}
			});
		} else if (e instanceof EventCachedInitial) {
			rootUpdates.add((EventCachedInitial) e);
			Display.getDefault().syncExec(new Runnable() {
				public void run() {
					handleCachedInitialEvent();
				}
			});
		} else {
			createInitialCache();
		}
	}

	public CachedASTNode getCache() {
		return myCache;
	}

	/**
	 * Create an {@link ITaskObject} caching the initial cache for the file of
	 * this cache.
	 * 
	 * @param root
	 *            The node to cache.
	 * @param cachedParent
	 *            For parent reference.
	 * @return A node containing the cache to display in the outline.
	 */
	protected abstract void createInitialCache();
}
