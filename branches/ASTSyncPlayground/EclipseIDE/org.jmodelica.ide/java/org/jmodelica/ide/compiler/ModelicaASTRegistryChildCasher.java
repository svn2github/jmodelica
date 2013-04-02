package org.jmodelica.ide.compiler;

import java.util.ArrayList;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jmodelica.ide.helpers.ASTNodeCacheFactory;
import org.jmodelica.ide.helpers.ICachedOutlineNode;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.SourceRoot;

public class ModelicaASTRegistryChildCasher {
	private ModelicaASTRegistry registry = ModelicaASTRegistry.getInstance();
	private IFile file;
	private Stack<String> nodePath;

	public ModelicaASTRegistryChildCasher(IFile file, Stack<String> nodePath) {
		this.file = file;
		this.nodePath = nodePath;
	}

	public ArrayList<ICachedOutlineNode> cacheChildren() {
		long time = System.currentTimeMillis();
		ArrayList<ICachedOutlineNode> toReturn = new ArrayList<ICachedOutlineNode>();
		LocalRootNode root = (LocalRootNode) registry.doLookup(file)[0];
		SourceRoot sroot = root.getSourceRoot();
		synchronized (sroot.state()) {
			ASTNode<?> sought = ModelicaASTRegistry.getInstance().resolveSourceASTPath(
					nodePath, sroot);
			if (sought == null)
				System.err
						.println("ModelicaASTRegistryChildCasher could not find the node of astPath...");
			ArrayList<?> children = sought.outlineChildren();
			for (Object obj : children)
				toReturn.add(ASTNodeCacheFactory.cacheNode((ASTNode<?>) obj,
						null, null));
		}
		System.out.println("ModelicaASTRegistryChildCacher took: "
				+ (System.currentTimeMillis() - time) + "ms");
		return toReturn;
	}
}
