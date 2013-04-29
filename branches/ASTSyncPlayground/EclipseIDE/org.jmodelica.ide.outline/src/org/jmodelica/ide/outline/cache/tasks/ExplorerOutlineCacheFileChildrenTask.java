package org.jmodelica.ide.outline.cache.tasks;

import java.util.ArrayList;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.helpers.ASTNodeCacheFactory;
import org.jmodelica.ide.helpers.ICachedOutlineNode;
import org.jmodelica.ide.helpers.OutlineCacheJob;
import org.jmodelica.ide.outline.cache.AbstractOutlineCache;
import org.jmodelica.ide.outline.cache.EventCachedFileChildren;
import org.jmodelica.ide.sync.GlobalRootNode;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.SourceRoot;

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
		SourceRoot sroot = ((GlobalRootNode) ModelicaASTRegistry.getInstance()
				.doLookup(file.getProject())).getSourceRoot();
		synchronized (sroot.state()) {
			toReturn = ASTNodeCacheFactory.cacheNode(sroot, file, cache);
			for (Object obj : sroot.outlineChildren())
				if (obj instanceof FullClassDecl) {
					FullClassDecl node = (FullClassDecl) obj;
					if (node.getDefinition().getFile().equals(file))
						children.add(ASTNodeCacheFactory.cacheNode(node,
								toReturn, cache));
				}
		}
		toReturn.setOutlineChildren(children);
		System.out.println("CacheFileChildren from ExplorerOutline took: "
				+ (System.currentTimeMillis() - time) + "ms for nbrchildren:"
				+ children.size() + " in file:" + file.getName());
		IASTChangeEvent event = new EventCachedFileChildren(file, toReturn);
		listener.astChanged(event);
	}

	protected void printRec(ASTNode<?> node, String indent) {
		System.err
				.println(indent + node.getNodeName() + ":" + node.outlineId());
		for (int i = 0; i < node.getNumChild(); i++)
			printRec(node.getChild(i), indent + " ");

	}
}