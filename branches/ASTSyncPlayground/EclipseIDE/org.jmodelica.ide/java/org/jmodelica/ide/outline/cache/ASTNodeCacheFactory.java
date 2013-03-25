package org.jmodelica.ide.outline.cache;

import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.ClassDecl;

public class ASTNodeCacheFactory {
	public static CachedASTNode cacheNode(ASTNode<?> node, Object parent,
			AbstractOutlineCache cache) {
		if (node instanceof ClassDecl) {
			return new CachedClassDecl((ClassDecl) node, parent, cache);
		} else {
			return new CachedASTNode(node, parent, cache);
		}
	}
}
