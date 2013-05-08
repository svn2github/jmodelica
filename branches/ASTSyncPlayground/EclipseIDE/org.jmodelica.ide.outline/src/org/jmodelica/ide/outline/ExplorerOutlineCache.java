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
import org.jmodelica.ide.outline.cache.EventCachedFileChildren;
import org.jmodelica.ide.outline.cache.tasks.ClassOutlineCacheChildrenTask;
import org.jmodelica.ide.outline.cache.tasks.ExplorerOutlineCacheFileChildrenTask;
import org.jmodelica.ide.sync.ASTPathPart;
import org.jmodelica.ide.sync.ASTRegTaskBucket;

public class ExplorerOutlineCache extends AbstractOutlineCache {
	private ArrayList<EventCachedFileChildren> childrenFileUpdates = new ArrayList<EventCachedFileChildren>();

	public ExplorerOutlineCache(IASTChangeListener listener) {
		super(listener);
	}

	protected void createInitialCache() {
	}

	public void fetchChildren(Stack<ASTPathPart> nodePath,
			ICachedOutlineNode node, Object task) {
		OutlineCacheJob job = new ClassOutlineCacheChildrenTask(this, nodePath,
				myFile, (OutlineUpdateWorker.ChildrenTask) task, this, node);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	public void fetchFileChildren(IFile file) {
		// Don't automagically expand file Models unless user clicks
		// expand...
		OutlineCacheJob job = new ExplorerOutlineCacheFileChildrenTask(this,
				file, this);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	protected synchronized void handleCachedFileChildrenEvent() {
		EventCachedFileChildren e = childrenFileUpdates.remove(0);
		myOutline.astChanged(e);
	}

	@Override
	public void astChanged(IASTChangeEvent e) {
		if (e instanceof EventCachedFileChildren) {
			childrenFileUpdates.add((EventCachedFileChildren) e);
			Display.getDefault().syncExec(new Runnable() {
				public void run() {
					handleCachedFileChildrenEvent();
				}
			});
		} else if (e.getType() == IASTChangeEvent.FILE_RECOMPILED) {
			fetchFileChildren(e.getFile());
		}
	}
}