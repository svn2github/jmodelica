package org.jmodelica.ide.outline.cache.tasks;

import java.util.ArrayList;
import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.helpers.ICachedOutlineNode;
import org.jmodelica.ide.helpers.OutlineCacheJob;
import org.jmodelica.ide.outline.cache.AbstractOutlineCache;
import org.jmodelica.ide.outline.cache.EventCachedInitial;
import org.jmodelica.ide.sync.ASTNodeCacheFactory;
import org.jmodelica.ide.sync.CachedASTNode;
import org.jmodelica.ide.sync.GlobalRootNode;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class SourceOutlineCacheInitialTask extends OutlineCacheJob {

	public SourceOutlineCacheInitialTask(IASTChangeListener listener,
			IFile file, AbstractOutlineCache cache) {
		super(listener, file, cache);
	}

	@Override
	public void doJob() {
		long time = System.currentTimeMillis();
		GlobalRootNode root = (GlobalRootNode) ModelicaASTRegistry
				.getInstance().doLookup(file.getProject());
		SourceRoot sroot = root.getSourceRoot();
		ArrayList<ICachedOutlineNode> children = new ArrayList<ICachedOutlineNode>();
		CachedASTNode toReturn = null;
		synchronized (sroot.state()) {
			toReturn = ASTNodeCacheFactory.cacheNode(sroot, null, cache);
			for (StoredDefinition def : sroot.getProgram()
					.getUnstructuredEntitys()) {
				if (def.getFile().equals(file)) {
					for (Object obj : def.outlineChildren())
						if (obj instanceof FullClassDecl)
							children.add(ASTNodeCacheFactory.cacheNode(
									(FullClassDecl) obj, toReturn, cache));
					break;
				}
			}
		}
		toReturn.setOutlineChildren(children);
		System.out.println("CacheChildren from SourceOutline took: "
				+ (System.currentTimeMillis() - time) + "ms");
		IASTChangeEvent event = new EventCachedInitial(toReturn);
		listener.astChanged(event);
	}
}