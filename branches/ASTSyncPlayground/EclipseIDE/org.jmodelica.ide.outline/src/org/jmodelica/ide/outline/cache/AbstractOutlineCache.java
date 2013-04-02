package org.jmodelica.ide.outline.cache;

import java.util.ArrayList;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.eclipse.swt.widgets.Display;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.compiler.IJobObject;
import org.jmodelica.ide.compiler.ModelicaASTRegistry;
import org.jmodelica.ide.helpers.CachedASTNode;
import org.jmodelica.ide.helpers.ICachedOutlineNode;
import org.jmodelica.ide.helpers.IOutlineCache;
import org.jmodelica.ide.outline.OutlineUpdateWorker;

public abstract class AbstractOutlineCache implements IOutlineCache,
		IASTChangeListener {
	protected IASTChangeListener myOutline;
	protected IFile myFile;
	private CachedASTNode myCache;
	private ArrayList<EventCachedChildren> childrenUpdates = new ArrayList<EventCachedChildren>();
	private ArrayList<EventCachedInitial> rootUpdates = new ArrayList<EventCachedInitial>();

	public AbstractOutlineCache(IASTChangeListener outline) {
		myOutline = outline;
	}

	public void setFile(IFile file) {
		myFile = file;
		createInitialCache();
		ModelicaASTRegistry.getInstance().addListener(file, null, this,
				IASTChangeListener.OUTLINE_LISTENER);
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
		ModelicaASTRegistry.getInstance().removeListener(myFile, null, this);
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
			System.out.println("YEAH cachedchildren event back in CACHE!!");
			childrenUpdates.add((EventCachedChildren) e);
			Display.getDefault().syncExec(new Runnable() {
				public void run() {
					handleCachedChildrenEvent();
				}
			});
		} else if (e instanceof EventCachedInitial) {
			System.out.println("YEAH cachedinitial event back in CACHE!!");
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
	 * Create an {@link IJobObject} caching the initial cache for the file of
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
