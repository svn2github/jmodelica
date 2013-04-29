package org.jmodelica.ide.outline.cache.tasks;

import java.util.ArrayList;
import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.helpers.ASTNodeCacheFactory;
import org.jmodelica.ide.helpers.CachedASTNode;
import org.jmodelica.ide.helpers.ICachedOutlineNode;
import org.jmodelica.ide.helpers.OutlineCacheJob;
import org.jmodelica.ide.outline.cache.AbstractOutlineCache;
import org.jmodelica.ide.outline.cache.EventCachedInitialNoLibs;
import org.jmodelica.ide.sync.GlobalRootNode;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.SourceRoot;

public class ClassOutlineCacheInitialNoLibsTask extends OutlineCacheJob {
	private int initialTreeCacheDepth = 1;

	public ClassOutlineCacheInitialNoLibsTask(IASTChangeListener listener, IFile file,
			AbstractOutlineCache cache) {
		super(listener, file, cache);
	}

	@Override
	public void doJob() {
		long time = System.currentTimeMillis();
		GlobalRootNode root = (GlobalRootNode) ModelicaASTRegistry.getInstance().doLookup(file.getProject());
		SourceRoot sroot = root.getSourceRoot();
		CachedASTNode cachedNode = null;
		synchronized (sroot.state()) {
			cachedNode = ASTNodeCacheFactory.cacheNode(sroot, null, cache);
			cacheChildren(sroot, cachedNode, initialTreeCacheDepth);
		}
		System.out.println("ClassOutlinePage initial caching (no Libs) took: "
				+ (System.currentTimeMillis() - time) + "ms");
		IASTChangeEvent event = new EventCachedInitialNoLibs(cachedNode);
		listener.astChanged(event);
	}

	private void cacheChildren(ASTNode<?> node, ICachedOutlineNode cachedNode,
			int depth) {
		if (depth > 0) {
			ArrayList<ICachedOutlineNode> children = new ArrayList<ICachedOutlineNode>();
			for (Object obj : node.outlineChildren()) {
				if (obj instanceof ASTNode<?>) {
					ASTNode<?> child = (ASTNode<?>) obj;
					CachedASTNode cachedChild = ASTNodeCacheFactory.cacheNode(
							child, cachedNode, cache);
					cacheChildren(child, cachedChild, depth - 1);
					children.add(cachedChild);
				}
			}
			cachedNode.setOutlineChildren(children);
		}
	}
}