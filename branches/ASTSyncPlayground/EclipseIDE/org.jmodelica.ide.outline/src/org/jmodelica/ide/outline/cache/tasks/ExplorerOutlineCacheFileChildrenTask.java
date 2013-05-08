package org.jmodelica.ide.outline.cache.tasks;

import java.util.ArrayList;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.helpers.ICachedOutlineNode;
import org.jmodelica.ide.helpers.OutlineCacheJob;
import org.jmodelica.ide.outline.cache.AbstractOutlineCache;
import org.jmodelica.ide.outline.cache.EventCachedFileChildren;
import org.jmodelica.ide.sync.ASTNodeCacheFactory;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class ExplorerOutlineCacheFileChildrenTask extends OutlineCacheJob {

	public ExplorerOutlineCacheFileChildrenTask(IASTChangeListener listener,
			IFile file, AbstractOutlineCache cache) {
		super(listener, file, cache);
	}

	@Override
	public void doJob() {
		long time = System.currentTimeMillis();
		ICachedOutlineNode toReturn = null;
		ArrayList<ICachedOutlineNode> children = new ArrayList<ICachedOutlineNode>();
		StoredDefinition def = ModelicaASTRegistry.getInstance().getLatestDef(
				file);
		synchronized (def.state()) {
			toReturn = ASTNodeCacheFactory.cacheNode(def, file, cache);
			for (Object obj : def.outlineChildren())
				if (obj instanceof FullClassDecl) {
					children.add(ASTNodeCacheFactory.cacheNode(
							(FullClassDecl) obj, toReturn, cache));
				}
		}
		toReturn.setOutlineChildren(children);
		System.out.println("CacheFileChildren from ExplorerOutline took: "
				+ (System.currentTimeMillis() - time) + "ms for nbrchildren:"
				+ children.size() + " in file:" + file.getName());
		IASTChangeEvent event = new EventCachedFileChildren(file, toReturn);
		listener.astChanged(event);
	}
}