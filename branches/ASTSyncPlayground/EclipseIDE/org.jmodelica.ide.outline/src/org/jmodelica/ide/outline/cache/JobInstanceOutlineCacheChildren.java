package org.jmodelica.ide.outline.cache;

import java.util.ArrayList;
import java.util.Stack;

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
import org.jmodelica.modelica.compiler.InstNode;
import org.jmodelica.modelica.compiler.InstProgramRoot;
import org.jmodelica.modelica.compiler.SourceRoot;

public class JobInstanceOutlineCacheChildren extends OutlineCacheJob {
	private Stack<String> nodePath;
	private ChildrenTask task;
	private ICachedOutlineNode parent;

	public JobInstanceOutlineCacheChildren(IASTChangeListener listener,
			Stack<String> nodePath, IFile file, ChildrenTask task,
			AbstractOutlineCache cache, ICachedOutlineNode parent) {
		super(listener, file, cache);
		this.nodePath = nodePath;
		this.task = task;
		this.parent = parent;
	}

	@Override
	public void doJob() {
		System.out
				.println("JobHandler handling CacheChildren from InstanceOutline...");
		long time = System.currentTimeMillis();
		ArrayList<ICachedOutlineNode> toReturn = new ArrayList<ICachedOutlineNode>();
		LocalRootNode root = (LocalRootNode) ModelicaASTRegistry.getInstance()
				.doLookup(file)[0];
		SourceRoot sroot = root.getSourceRoot();
		synchronized (sroot.state()) {
			InstProgramRoot iRoot = sroot.getProgram().getInstProgramRoot();
			long time2 = System.currentTimeMillis();
			InstNode sought = ModelicaASTRegistry.getInstance()
					.resolveInstanceASTPath(nodePath, iRoot);
			System.out.println("ModelicaASTReg: ResolveInstPath() took: "
					+ (System.currentTimeMillis() - time2) + "ms");
			for (Object obj : sought.instClassDecls())
				toReturn.add(ASTNodeCacheFactory.cacheNode((ASTNode<?>) obj,
						parent, cache));
			for (Object obj : sought.instComponentDecls())
				toReturn.add(ASTNodeCacheFactory.cacheNode((ASTNode<?>) obj,
						parent, cache));
		}
		System.out.println("CacheChildren from InstanceOutline took: "
				+ (System.currentTimeMillis() - time) + "ms");
		IASTChangeEvent event = new EventCachedChildren(toReturn, task);
		listener.astChanged(event);
	}
}