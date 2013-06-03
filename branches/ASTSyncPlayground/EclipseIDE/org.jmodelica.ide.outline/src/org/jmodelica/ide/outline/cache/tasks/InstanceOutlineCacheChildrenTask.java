package org.jmodelica.ide.outline.cache.tasks;

import java.util.ArrayList;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jastadd.ed.core.model.IASTPathPart;
import org.jastadd.ed.core.model.node.ICachedOutlineNode;
import org.jmodelica.ide.outline.OutlineUpdateWorker.ChildrenTask;
import org.jmodelica.ide.outline.cache.AbstractOutlineCache;
import org.jmodelica.ide.outline.cache.EventCachedChildren;
import org.jmodelica.ide.sync.ASTNodeCacheFactory;
import org.jmodelica.ide.sync.GlobalRootNode;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.ide.sync.OutlineCacheJob;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.InstNode;
import org.jmodelica.modelica.compiler.InstProgramRoot;
import org.jmodelica.modelica.compiler.SourceRoot;

public class InstanceOutlineCacheChildrenTask extends OutlineCacheJob {
	private Stack<IASTPathPart> nodePath;
	private ChildrenTask task;

	public InstanceOutlineCacheChildrenTask(IASTChangeListener listener,
			Stack<IASTPathPart> nodePath, IFile file, ChildrenTask task,
			AbstractOutlineCache cache) {
		super(listener, file, cache);
		this.nodePath = nodePath;
		this.task = task;
	}

	@Override
	public void doJob() {
		ArrayList<ICachedOutlineNode> toReturn = new ArrayList<ICachedOutlineNode>();
		GlobalRootNode root = (GlobalRootNode) ModelicaASTRegistry
				.getInstance().doLookup(file.getProject());
		SourceRoot sroot = root.getSourceRoot();
		synchronized (sroot.state()) {
			InstProgramRoot iRoot = sroot.getProgram().getInstProgramRoot();
			InstNode sought = ModelicaASTRegistry.getInstance()
					.resolveInstanceASTPath(nodePath, iRoot);
			for (Object obj : sought.instClassDecls())
				toReturn.add(ASTNodeCacheFactory.cacheNode((ASTNode<?>) obj,
						task.node, cache));
			for (Object obj : sought.instComponentDecls())
				toReturn.add(ASTNodeCacheFactory.cacheNode((ASTNode<?>) obj,
						task.node, cache));
		}
		IASTChangeEvent event = new EventCachedChildren(toReturn, task);
		listener.astChanged(event);
	}
}