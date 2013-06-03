package org.jmodelica.ide.outline;

import java.util.Stack;

import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jastadd.ed.core.model.IASTPathPart;
import org.jmodelica.ide.outline.cache.AbstractOutlineCache;
import org.jmodelica.ide.outline.cache.EventCachedChildren;
import org.jmodelica.ide.outline.cache.EventCachedInitial;
import org.jmodelica.ide.outline.cache.tasks.ClassOutlineCacheChildrenTask;
import org.jmodelica.ide.outline.cache.tasks.SourceOutlineCacheInitialTask;
import org.jmodelica.ide.sync.ASTRegTaskBucket;
import org.jmodelica.ide.sync.OutlineCacheJob;

public class SourceOutlineCache extends AbstractOutlineCache {

	public SourceOutlineCache(IASTChangeListener sourceOutline) {
		super(sourceOutline);
	}

	@Override
	protected void createInitialCache() {
		OutlineCacheJob job = new SourceOutlineCacheInitialTask(this, myFile,
				this);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	public void fetchChildren(Stack<IASTPathPart> nodePath, Object task) {
		OutlineCacheJob job = new ClassOutlineCacheChildrenTask(this, nodePath,
				myFile, (OutlineUpdateWorker.ChildrenTask) task, this);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	public void astChanged(IASTChangeEvent e) {
		if (e instanceof EventCachedChildren || e instanceof EventCachedInitial) {
			super.astChanged(e);
		} else if (e.getType() == IASTChangeEvent.FILE_RECOMPILED) {
			createInitialCache();
		}
	}
}
