package org.jmodelica.ide.outline.cache;

import java.util.ArrayList;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.compiler.LocalRootNode;
import org.jmodelica.ide.compiler.ModelicaASTRegistry;
import org.jmodelica.ide.helpers.ASTNodeCacheFactory;
import org.jmodelica.ide.helpers.ICachedOutlineNode;
import org.jmodelica.ide.helpers.OutlineCacheJob;
import org.jmodelica.ide.outline.OutlineUpdateWorker.ChildrenTask;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class JobExplorerOutlineCacheFileChildren extends OutlineCacheJob {

	private ChildrenTask task;

	public JobExplorerOutlineCacheFileChildren(IASTChangeListener listener,
			IFile file, AbstractOutlineCache cache, ChildrenTask task) {
		super(listener, file, cache);
		this.task = task;
	}

	@Override
	public void doJob() {
		System.out
				.println("JobHandler handling CacheFileChildren from ExplorerOutline... File:"+file.getName());
		long time = System.currentTimeMillis();
		ICachedOutlineNode toReturn = null;
		ArrayList<ICachedOutlineNode> children = new ArrayList<ICachedOutlineNode>();
		LocalRootNode root = (LocalRootNode) ModelicaASTRegistry.getInstance()
				.doLookup(file)[0];
		StoredDefinition def = root.getStoredDef();
		synchronized (def.state()) {
			toReturn = ASTNodeCacheFactory.cacheNode(def, file, cache);
			for (Object obj : def.getElements())
				if (obj instanceof ASTNode<?>)
				children.add(ASTNodeCacheFactory.cacheNode((ASTNode<?>) obj,
						toReturn, cache));
		}
		toReturn.setOutlineChildren(children);
		System.out.println("CacheFileChildren from ExplorerOutline took: "
				+ (System.currentTimeMillis() - time) + "ms for nbrchildren:"+children.size()+" in file:"+file.getName());
		IASTChangeEvent event = new EventCachedFileChildren(file, toReturn,
				task);
		listener.astChanged(event);
	}
}
