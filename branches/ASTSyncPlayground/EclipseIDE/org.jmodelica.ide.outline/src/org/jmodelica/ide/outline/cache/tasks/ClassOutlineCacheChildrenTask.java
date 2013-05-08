package org.jmodelica.ide.outline.cache.tasks;

import java.util.ArrayList;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.helpers.ICachedOutlineNode;
import org.jmodelica.ide.helpers.OutlineCacheJob;
import org.jmodelica.ide.outline.OutlineUpdateWorker.ChildrenTask;
import org.jmodelica.ide.outline.cache.AbstractOutlineCache;
import org.jmodelica.ide.outline.cache.EventCachedChildren;
import org.jmodelica.ide.sync.ASTNodeCacheFactory;
import org.jmodelica.ide.sync.ASTPathPart;
import org.jmodelica.ide.sync.GlobalRootNode;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.SourceRoot;

public class ClassOutlineCacheChildrenTask extends OutlineCacheJob {
	private Stack<ASTPathPart> nodePath;
	private ChildrenTask task;
	private ICachedOutlineNode parent;

	public ClassOutlineCacheChildrenTask(IASTChangeListener listener,
			Stack<ASTPathPart> nodePath, IFile file, ChildrenTask task,
			AbstractOutlineCache cache, ICachedOutlineNode parent) {
		super(listener, file, cache);
		this.nodePath = nodePath;
		this.task = task;
		this.parent = parent;
	}

	@Override
	public void doJob() {
		long time = System.currentTimeMillis();
		ArrayList<ICachedOutlineNode> toReturn = new ArrayList<ICachedOutlineNode>();
		GlobalRootNode root = (GlobalRootNode) ModelicaASTRegistry
				.getInstance().doLookup(file.getProject());
		SourceRoot sroot = root.getSourceRoot();
		synchronized (sroot.state()) {
			ASTNode<?> sought = ModelicaASTRegistry.getInstance()
					.resolveSourceASTPath(nodePath, sroot);
			for (Object obj : sought.outlineChildren())
				toReturn.add(ASTNodeCacheFactory.cacheNode((ASTNode<?>) obj,
						parent, cache));
		}
		System.out.println("CacheChildren from ClassOutline took: "
				+ (System.currentTimeMillis() - time) + "ms");
		IASTChangeEvent event = new EventCachedChildren(toReturn, task);
		listener.astChanged(event);
	}
}