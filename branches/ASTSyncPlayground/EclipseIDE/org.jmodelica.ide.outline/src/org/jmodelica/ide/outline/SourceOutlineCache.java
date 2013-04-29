package org.jmodelica.ide.outline;

import java.util.Stack;

import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.helpers.ICachedOutlineNode;
import org.jmodelica.ide.helpers.OutlineCacheJob;
import org.jmodelica.ide.outline.cache.AbstractOutlineCache;
import org.jmodelica.ide.outline.cache.EventCachedInitial;
import org.jmodelica.ide.outline.cache.tasks.ClassOutlineCacheChildrenTask;
import org.jmodelica.ide.outline.cache.tasks.SourceOutlineCacheInitialTask;
import org.jmodelica.ide.sync.ASTRegTaskBucket;

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
	public void fetchChildren(Stack<String> nodePath, ICachedOutlineNode node,
			Object task) {
		OutlineCacheJob job = new ClassOutlineCacheChildrenTask(this, nodePath,
				myFile, (OutlineUpdateWorker.ChildrenTask) task, this, node);
		ASTRegTaskBucket.getInstance().addTask(job);
	}
	
	@Override
	public void astChanged(IASTChangeEvent e) {
		if (e instanceof EventCachedInitial) {
			super.astChanged(e);
		} else if (e.getType() == IASTChangeEvent.FILE_RECOMPILED){
			createInitialCache();
		}
	}
}
