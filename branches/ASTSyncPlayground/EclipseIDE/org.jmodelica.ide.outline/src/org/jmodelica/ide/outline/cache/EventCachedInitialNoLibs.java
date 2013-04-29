package org.jmodelica.ide.outline.cache;

import org.jastadd.ed.core.model.ASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jmodelica.ide.helpers.CachedASTNode;

/**
 * We don't want to flush/re-cache MSL on file re-compilations.
 * @author JL
 *
 */
public class EventCachedInitialNoLibs extends ASTChangeEvent {
	private CachedASTNode cachedRoot;

	public EventCachedInitialNoLibs(CachedASTNode cachedRoot) {
		super(IASTChangeEvent.CACHED_CHILDREN, IASTChangeEvent.FILE_LEVEL);
		this.cachedRoot = cachedRoot;
	}

	public CachedASTNode getCachedRoot() {
		return cachedRoot;
	}
}