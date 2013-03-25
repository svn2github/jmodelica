package org.jmodelica.ide.outline;

import java.util.Stack;

import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.compiler.ModelicaASTRegistryJobBucket;
import org.jmodelica.ide.outline.OutlineUpdateWorker.ChildrenTask;
import org.jmodelica.ide.outline.cache.AbstractOutlineCache;
import org.jmodelica.ide.outline.cache.ICachedOutlineNode;
import org.jmodelica.ide.outline.cache.JobInstanceOutlineCacheChildren;
import org.jmodelica.ide.outline.cache.JobInstanceOutlineCacheInitial;
import org.jmodelica.ide.outline.cache.OutlineCacheJob;

public class InstanceOutlineCache extends AbstractOutlineCache {

	public InstanceOutlineCache(IASTChangeListener listener) {
		super(listener);
	}

	@Override
	protected void createInitialCache() {
		OutlineCacheJob job = new JobInstanceOutlineCacheInitial(this, myFile,
				this);
		ModelicaASTRegistryJobBucket.getInstance().addJob(job);
	}

	@Override
	public void fetchChildren(Stack<String> nodePath, ICachedOutlineNode node,
			ChildrenTask task) {
		OutlineCacheJob job = new JobInstanceOutlineCacheChildren(this, nodePath,
				myFile, task, this, node);
		ModelicaASTRegistryJobBucket.getInstance().addJob(job);
	}
}
