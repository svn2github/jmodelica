package org.jmodelica.ide.outline;

import java.util.Stack;

import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.compiler.ModelicaASTRegistryJobBucket;
import org.jmodelica.ide.outline.OutlineUpdateWorker.ChildrenTask;
import org.jmodelica.ide.outline.cache.AbstractOutlineCache;
import org.jmodelica.ide.outline.cache.ICachedOutlineNode;
import org.jmodelica.ide.outline.cache.JobClassOutlineCacheChildren;
import org.jmodelica.ide.outline.cache.JobClassOutlineCacheInitial;
import org.jmodelica.ide.outline.cache.OutlineCacheJob;

public class ClassOutlineCache extends AbstractOutlineCache {
	public ClassOutlineCache(IASTChangeListener listener) {
		super(listener);
	}

	protected void createInitialCache() {
		OutlineCacheJob job = new JobClassOutlineCacheInitial(this, myFile,
				this);
		ModelicaASTRegistryJobBucket.getInstance().addJob(job);
	}

	public void fetchChildren(Stack<String> nodePath, ICachedOutlineNode node,
			ChildrenTask task) {
		OutlineCacheJob job = new JobClassOutlineCacheChildren(this, nodePath,
				myFile, task, this, node);
		ModelicaASTRegistryJobBucket.getInstance().addJob(job);
	}
}