package org.jmodelica.ide.outline;

import java.util.ArrayList;
import java.util.Stack;
import org.eclipse.core.resources.IFile;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.widgets.Display;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.compiler.ModelicaASTRegistryJobBucket;
import org.jmodelica.ide.outline.OutlineUpdateWorker.ChildrenTask;
import org.jmodelica.ide.outline.cache.AbstractOutlineCache;
import org.jmodelica.ide.outline.cache.EventCachedFileChildren;
import org.jmodelica.ide.outline.cache.ICachedOutlineNode;
import org.jmodelica.ide.outline.cache.JobClassOutlineCacheChildren;
import org.jmodelica.ide.outline.cache.JobExplorerOutlineCacheFileChildren;
import org.jmodelica.ide.outline.cache.OutlineCacheJob;

public class ExplorerOutlineCache extends AbstractOutlineCache {
	private ArrayList<EventCachedFileChildren> childrenFileUpdates = new ArrayList<EventCachedFileChildren>();

	public ExplorerOutlineCache(IASTChangeListener listener) {
		super(listener);
	}

	protected void createInitialCache() {
	}

	public void fetchChildren(Stack<String> nodePath, ICachedOutlineNode node,
			ChildrenTask task) {
		OutlineCacheJob job = new JobClassOutlineCacheChildren(this, nodePath,
				myFile, task, this, node);
		ModelicaASTRegistryJobBucket.getInstance().addJob(job);
	}

	public void fetchFileChildren(IFile file, TreeViewer viewer) {
		ChildrenTask task = new ChildrenTask(viewer, file);
		//Don't automagically expand file Models unless user clickes expand...
		task.expandDepth = 0;
		OutlineCacheJob job = new JobExplorerOutlineCacheFileChildren(this,
				file, this, task);
		ModelicaASTRegistryJobBucket.getInstance().addJob(job);
	}

	protected synchronized void handleCachedFileChildrenEvent() {
		EventCachedFileChildren e = childrenFileUpdates.remove(0);
		myOutline.astChanged(e);
	}

	@Override
	public void astChanged(IASTChangeEvent e) {
		if (e instanceof EventCachedFileChildren) {
			System.out
					.println("YEAH CacheFileChildren event back in ExplorerOutlineCache!!");
			childrenFileUpdates.add((EventCachedFileChildren) e);
			Display.getDefault().syncExec(new Runnable() {
				public void run() {
					handleCachedFileChildrenEvent();
				}
			});
		} else {
			super.astChanged(e);
		}
	}
}