package org.jmodelica.ide.outline.cache.tasks;

import java.util.ArrayList;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jastadd.ed.core.model.node.ICachedOutlineNode;
import org.jmodelica.ide.outline.cache.AbstractOutlineCache;
import org.jmodelica.ide.outline.cache.EventCachedInitial;
import org.jmodelica.ide.sync.ASTNodeCacheFactory;
import org.jmodelica.ide.sync.CachedASTNode;
import org.jmodelica.ide.sync.GlobalRootNode;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.ide.sync.OutlineCacheJob;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstProgramRoot;
import org.jmodelica.modelica.compiler.SourceRoot;

public class InstanceOutlineCacheInitialTask extends OutlineCacheJob {

	public InstanceOutlineCacheInitialTask(IASTChangeListener listener,
			IFile file, AbstractOutlineCache cache) {
		super(listener, file, cache);
	}

	@Override
	public void doJob() {
		GlobalRootNode root = (GlobalRootNode) ModelicaASTRegistry
				.getInstance().doLookup(file.getProject());
		SourceRoot sroot = root.getSourceRoot();
		CachedASTNode toReturn = null;
		String filePath = file.getLocation().toOSString();
		ArrayList<ICachedOutlineNode> children = new ArrayList<ICachedOutlineNode>();
		synchronized (sroot) {
			InstProgramRoot iRoot = sroot.getProgram().getInstProgramRoot();
			toReturn = ASTNodeCacheFactory.cacheNode(iRoot, null, cache);
			for (InstClassDecl inst : iRoot.instClassDecls()) {
				if (inst.containingFileName().equals(filePath)) {
					CachedASTNode cachedNode = ASTNodeCacheFactory.cacheNode(
							inst, toReturn, cache);
					// Also cache children initially?
					/**
					 * ArrayList<?> comps = inst.outlineChildren();
					 * ArrayList<ICachedOutlineNode> cacc = new
					 * ArrayList<ICachedOutlineNode>(); for (Object obj : comps)
					 * { cacc.add(ASTNodeCacheFactory.cacheNode( (ASTNode<?>)
					 * obj, cachedNode, cache)); }
					 * cachedNode.setOutlineChildren(cacc);
					 */
					children.add(cachedNode);
				}
			}
		}
		toReturn.setOutlineChildren(children);
		IASTChangeEvent event = new EventCachedInitial(toReturn);
		listener.astChanged(event);
	}
}