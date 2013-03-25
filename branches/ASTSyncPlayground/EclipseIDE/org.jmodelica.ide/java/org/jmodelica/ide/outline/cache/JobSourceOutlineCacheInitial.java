package org.jmodelica.ide.outline.cache;

import java.util.ArrayList;
import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.compiler.LocalRootNode;
import org.jmodelica.ide.compiler.ModelicaASTRegistry;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.SourceRoot;

public class JobSourceOutlineCacheInitial extends OutlineCacheJob {

	public JobSourceOutlineCacheInitial(IASTChangeListener listener,
			IFile file, AbstractOutlineCache cache) {
		super(listener, file, cache);
	}

	@Override
	public void doJob() {
		System.out
				.println("JobHandler handling CacheChildren from SourceOutline...");
		long time = System.currentTimeMillis();
		LocalRootNode root = (LocalRootNode) ModelicaASTRegistry.getInstance()
				.doLookup(file)[0];
		SourceRoot sroot = root.getSourceRoot();
		ArrayList<ICachedOutlineNode> children = new ArrayList<ICachedOutlineNode>();
		CachedASTNode toReturn = null;
		synchronized (sroot.state()) {
			toReturn = ASTNodeCacheFactory.cacheNode(sroot, null, cache);
			for (Object obj : sroot.outlineChildren())
				if (obj instanceof ASTNode<?>)
					children.add(ASTNodeCacheFactory.cacheNode(
							(ASTNode<?>) obj, toReturn, cache));
		}
		toReturn.setOutlineChildren(children);
		System.out.println("CacheChildren from SourceOutline took: "
				+ (System.currentTimeMillis() - time) + "ms for nbrchild: "
				+ children.size());
		IASTChangeEvent event = new EventCachedInitial(toReturn);
		listener.astChanged(event);
	}
}