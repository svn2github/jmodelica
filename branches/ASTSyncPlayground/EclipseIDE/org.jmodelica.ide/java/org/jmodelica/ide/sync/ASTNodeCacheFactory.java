package org.jmodelica.ide.sync;

import org.jastadd.ed.core.model.IOutlineCache;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.ClassDecl;

public class ASTNodeCacheFactory {
	public static CachedASTNode cacheNode(ASTNode<?> node, Object parent,
			IOutlineCache cache) {
		if (node instanceof ClassDecl) {
			return new CachedClassDecl((ClassDecl) node, parent, cache);
		} else {
			return new CachedASTNode(node, parent, cache);
		}
	}
}
