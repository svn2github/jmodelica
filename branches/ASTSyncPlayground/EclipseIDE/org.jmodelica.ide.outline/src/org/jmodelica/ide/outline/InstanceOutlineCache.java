package org.jmodelica.ide.outline;

import java.util.Stack;

import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.helpers.ICachedOutlineNode;
import org.jmodelica.ide.helpers.OutlineCacheJob;
import org.jmodelica.ide.outline.cache.AbstractOutlineCache;
import org.jmodelica.ide.outline.cache.tasks.InstanceOutlineCacheChildrenTask;
import org.jmodelica.ide.outline.cache.tasks.InstanceOutlineCacheInitialTask;
import org.jmodelica.ide.sync.ASTPathPart;
import org.jmodelica.ide.sync.ASTRegTaskBucket;

public class InstanceOutlineCache extends AbstractOutlineCache {

	public InstanceOutlineCache(IASTChangeListener listener) {
		super(listener);
	}

	@Override
	protected void createInitialCache() {
		OutlineCacheJob job = new InstanceOutlineCacheInitialTask(this, myFile,
				this);
		ASTRegTaskBucket.getInstance().addTask(job);
	}

	@Override
	public void fetchChildren(Stack<ASTPathPart> nodePath,
			ICachedOutlineNode node, Object task) {
		OutlineCacheJob job = new InstanceOutlineCacheChildrenTask(this,
				nodePath, myFile, (OutlineUpdateWorker.ChildrenTask) task,
				this, node);
		ASTRegTaskBucket.getInstance().addTask(job);
	}
}
