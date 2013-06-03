package org.jmodelica.ide.outline.cache;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.ASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.node.ICachedOutlineNode;

public class EventCachedFileChildren extends ASTChangeEvent implements
		IASTChangeEvent {

	private ICachedOutlineNode root;
	private IFile file;

	public EventCachedFileChildren(IFile file, ICachedOutlineNode root) {
		super(IASTChangeEvent.CACHED_CHILDREN, IASTChangeEvent.FILE_LEVEL);
		this.root = root;
		this.file = file;
	}

	public ICachedOutlineNode getRoot() {
		return root;
	}

	public IFile getFile() {
		return file;
	}
}