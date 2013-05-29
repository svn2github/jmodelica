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
import org.jmodelica.ide.sync.GlobalRootNode;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class ExplorerOutlineCacheFileChildrenTask extends OutlineCacheJob {

	public ExplorerOutlineCacheFileChildrenTask(IASTChangeListener listener,
			IFile file, AbstractOutlineCache cache) {
		super(listener, file, cache);
	}

	@Override
	public void doJob() {
		ICachedOutlineNode toReturn = null;
		ArrayList<ICachedOutlineNode> children = new ArrayList<ICachedOutlineNode>();
		SourceRoot root = ((GlobalRootNode) ModelicaASTRegistry.getInstance()
				.doLookup(file.getProject())).getSourceRoot();
		synchronized (root.state()) {
			toReturn = ASTNodeCacheFactory.cacheNode(root, file, cache);
			for (StoredDefinition def : root.getProgram()
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
		IASTChangeEvent event = new EventCachedFileChildren(file, toReturn);
		listener.astChanged(event);
	}
}