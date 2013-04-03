package org.jmodelica.ide.outline;

import java.util.Stack;

import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.compiler.ModelicaASTRegistryJobBucket;
import org.jmodelica.ide.helpers.ICachedOutlineNode;
import org.jmodelica.ide.helpers.OutlineCacheJob;
import org.jmodelica.ide.outline.cache.AbstractOutlineCache;
import org.jmodelica.ide.outline.cache.JobInstanceOutlineCacheChildren;
import org.jmodelica.ide.outline.cache.JobInstanceOutlineCacheInitial;

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
			Object task) {
		OutlineCacheJob job = new JobInstanceOutlineCacheChildren(this,
				nodePath, myFile, (OutlineUpdateWorker.ChildrenTask) task,
				this, node);
		ModelicaASTRegistryJobBucket.getInstance().addJob(job);
	}
}
