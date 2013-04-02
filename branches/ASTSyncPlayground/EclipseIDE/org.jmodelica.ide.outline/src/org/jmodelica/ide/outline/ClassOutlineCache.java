package org.jmodelica.ide.outline;

import java.util.Stack;

import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.compiler.ModelicaASTRegistryJobBucket;
import org.jmodelica.ide.helpers.ICachedOutlineNode;
import org.jmodelica.ide.helpers.OutlineCacheJob;
import org.jmodelica.ide.outline.OutlineUpdateWorker.ChildrenTask;
import org.jmodelica.ide.outline.cache.AbstractOutlineCache;
import org.jmodelica.ide.outline.cache.JobClassOutlineCacheChildren;
import org.jmodelica.ide.outline.cache.JobClassOutlineCacheInitial;

public class ClassOutlineCache extends AbstractOutlineCache {
	public ClassOutlineCache(IASTChangeListener listener) {
		super(listener);
	}

	protected void createInitialCache() {
		OutlineCacheJob job = new JobClassOutlineCacheInitial(this, myFile,
				this);
		ModelicaASTRegistryJobBucket.getInstance().addJob(job);
	}

	@Override
	public void fetchChildren(Stack<String> nodePath, ICachedOutlineNode node,
			Object task) {
		OutlineCacheJob job = new JobClassOutlineCacheChildren(this, nodePath,
				myFile, (OutlineUpdateWorker.ChildrenTask) task, this, node);
		ModelicaASTRegistryJobBucket.getInstance().addJob(job);
	}
}