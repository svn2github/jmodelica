package org.jmodelica.ide.outline.cache;

import java.util.ArrayList;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.compiler.LocalRootNode;
import org.jmodelica.ide.compiler.ModelicaASTRegistry;
import org.jmodelica.ide.outline.LoadedLibraries;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.SourceRoot;

public class JobClassOutlineCacheInitial extends OutlineCacheJob {
	private int initialTreeCacheDepth = 1;

	public JobClassOutlineCacheInitial(IASTChangeListener listener, IFile file,
			AbstractOutlineCache cache) {
		super(listener, file, cache);
	}

	@Override
	public void doJob() {
		long time = System.currentTimeMillis();
		LocalRootNode root = (LocalRootNode) ModelicaASTRegistry.getInstance()
				.doLookup(file)[0];
		SourceRoot sroot = root.getSourceRoot();
		CachedASTNode cachedNode = null;
		synchronized (sroot.state()) {
			cachedNode = ASTNodeCacheFactory.cacheNode(sroot, null, cache);
			cacheChildren(sroot, cachedNode, initialTreeCacheDepth);
		}
		System.out.println("ClassOutlinePage initial caching took: "
				+ (System.currentTimeMillis() - time) + "ms");
		IASTChangeEvent event = new EventCachedInitial(cachedNode);
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
				} else if (obj instanceof LoadedLibraries) {
					long time = System.currentTimeMillis();
					LoadedLibraries lib = (LoadedLibraries) obj;
					Stack<String> astPath = ModelicaASTRegistry.getInstance()
							.createPath(node);
					astPath.add(0, lib.getText());
					lib.setASTPath(astPath);
					lib.setParent(cachedNode);
					ArrayList<ICachedOutlineNode> libChildren = new ArrayList<ICachedOutlineNode>();
					for (ASTNode<?> child : lib.getChildren()) {
						CachedASTNode cachedChild = ASTNodeCacheFactory
								.cacheNode(child, lib, cache);
						cacheChildren(child, cachedChild, depth - 1);
						libChildren.add(cachedChild);
					}
					lib.setOutlineChildren(libChildren);
					children.add(lib);
					System.out.println(lib.getText() + " took: "
							+ (System.currentTimeMillis() - time) + "ms");
				}
			}
			cachedNode.setOutlineChildren(children);
		}
	}
}