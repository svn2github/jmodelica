package org.jmodelica.ide.outline;

import java.util.ArrayList;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.eclipse.swt.widgets.Display;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.helpers.ICachedOutlineNode;
import org.jmodelica.ide.helpers.OutlineCacheJob;
import org.jmodelica.ide.outline.cache.AbstractOutlineCache;
import org.jmodelica.ide.outline.cache.EventCachedChildren;
import org.jmodelica.ide.outline.cache.EventCachedInitial;
import org.jmodelica.ide.outline.cache.EventCachedInitialNoLibs;
import org.jmodelica.ide.outline.cache.tasks.ClassOutlineCacheChildrenTask;
import org.jmodelica.ide.outline.cache.tasks.ClassOutlineCacheInitialTask;
import org.jmodelica.ide.outline.cache.tasks.ClassOutlineCacheInitialNoLibsTask;
import org.jmodelica.ide.sync.ASTPathPart;
import org.jmodelica.ide.sync.ASTRegTaskBucket;
import org.jmodelica.ide.sync.CachedASTNode;
import org.jmodelica.ide.sync.ChangePropagationController;
import org.jmodelica.ide.sync.ListenerObject;

public class ClassOutlineCache extends AbstractOutlineCache {
	protected ArrayList<EventCachedInitialNoLibs> eventCachedInitialNoLibs = new ArrayList<EventCachedInitialNoLibs>();

	public ClassOutlineCache(IASTChangeListener listener) {
		super(listener);
	}

	protected void createInitialCache() {
		OutlineCacheJob job = new ClassOutlineCacheInitialTask(this, myFile,
				this);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	public void fetchChildren(Stack<ASTPathPart> nodePath, Object task) {
		OutlineCacheJob job = new ClassOutlineCacheChildrenTask(this, nodePath,
				myFile, (OutlineUpdateWorker.ChildrenTask) task, this);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	public void astChanged(IASTChangeEvent e) {
		if (e instanceof EventCachedChildren || e instanceof EventCachedInitial) {
			super.astChanged(e);
		} else if (e.getType() == IASTChangeEvent.FILE_RECOMPILED) {
			createInitialCacheNoLibs();
		} else if (e instanceof EventCachedInitialNoLibs) {
			eventCachedInitialNoLibs.add((EventCachedInitialNoLibs) e);
			Display.getDefault().syncExec(new Runnable() {
				public void run() {
					handleCachedInitialNoLibsEvent();
				}
			});
		}
	}

	public void addFileListener(IFile file) {
		ListenerObject listObj = new ListenerObject(this,
				IASTChangeListener.OUTLINE_LISTENER, listenerID);
		ChangePropagationController.getInstance().addListener(listObj, file,
				null);
	}

	public void removeFileListener(IFile file) {
		ChangePropagationController.getInstance().removeListener(this, file,
				null);
	}

	protected void handleCachedInitialNoLibsEvent() {
		if (!eventCachedInitialNoLibs.isEmpty()) {
			EventCachedInitialNoLibs event = eventCachedInitialNoLibs.remove(0);
			ArrayList<ICachedOutlineNode> newChildren = new ArrayList<ICachedOutlineNode>();
			Object[] children = myCache.cachedOutlineChildren();
			for (Object obj : children)
				if (!(obj instanceof CachedASTNode))
					newChildren.add((ICachedOutlineNode) obj);
			CachedASTNode node = event.getCachedRoot();
			for (Object obj : node.cachedOutlineChildren())
				newChildren.add((ICachedOutlineNode) obj);
			myCache.setOutlineChildren(newChildren);
			myOutline.astChanged(null);
		}
	}

	private void createInitialCacheNoLibs() {
		OutlineCacheJob job = new ClassOutlineCacheInitialNoLibsTask(this,
				myFile, this);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

}