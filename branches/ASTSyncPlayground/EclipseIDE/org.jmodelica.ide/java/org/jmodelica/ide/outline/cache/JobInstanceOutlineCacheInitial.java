package org.jmodelica.ide.outline.cache;

import java.util.ArrayList;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.compiler.LocalRootNode;
import org.jmodelica.ide.compiler.ModelicaASTRegistry;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstProgramRoot;

public class JobInstanceOutlineCacheInitial extends OutlineCacheJob {

	public JobInstanceOutlineCacheInitial(IASTChangeListener listener,
			IFile file, AbstractOutlineCache cache) {
		super(listener, file, cache);
	}

	@Override
	public void doJob() {
		System.out
				.println("JobHandler handling InitialCache from InstanceOutline...");
		long time = System.currentTimeMillis();
		LocalRootNode root = (LocalRootNode) ModelicaASTRegistry.getInstance()
				.doLookup(file)[0];
		CachedASTNode toReturn = null;
		ArrayList<ICachedOutlineNode> children = new ArrayList<ICachedOutlineNode>();
		synchronized (root.getSourceRoot()) {
			InstProgramRoot iRoot = root.getSourceRoot().getProgram().getInstProgramRoot();
			toReturn = ASTNodeCacheFactory.cacheNode(iRoot, null, cache);
			ArrayList<?> classes = root.getStoredDef().getElements()
					.toArrayList();
			for (InstClassDecl inst : iRoot.instClassDecls()) {
				if (classes.contains(inst.getClassDecl())) {
					CachedASTNode cachedNode = ASTNodeCacheFactory.cacheNode(
							inst, toReturn, cache);
				/**	ArrayList<?> comps = inst.outlineChildren();
					ArrayList<ICachedOutlineNode> cacc = new ArrayList<ICachedOutlineNode>();
					for (Object obj : comps) {
						cacc.add(ASTNodeCacheFactory.cacheNode(
								(ASTNode<?>) obj, cachedNode, cache));
					}
					cachedNode.setOutlineChildren(cacc);*/
					children.add(cachedNode);
				}
			}
		}
		toReturn.setOutlineChildren(children);
		System.out.println("InstanceOutlinePage caching took:"
				+ (System.currentTimeMillis() - time) + "ms");
		IASTChangeEvent event = new EventCachedInitial(toReturn);
		listener.astChanged(event);
	}
}
