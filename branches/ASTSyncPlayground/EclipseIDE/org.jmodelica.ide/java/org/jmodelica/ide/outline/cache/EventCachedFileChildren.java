package org.jmodelica.ide.outline.cache;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.ASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jmodelica.ide.outline.OutlineUpdateWorker.ChildrenTask;

public class EventCachedFileChildren extends ASTChangeEvent implements
		IASTChangeEvent {

	private ICachedOutlineNode root;
	private ChildrenTask task;
	private IFile file;

	public EventCachedFileChildren(IFile file, ICachedOutlineNode root,
			ChildrenTask task) {
		super(IASTChangeEvent.CACHED_CHILDREN, IASTChangeEvent.FILE_LEVEL,
				null, null, null);
		this.task = task;
		this.root = root;
		this.file = file;
	}

	public ChildrenTask getTask() {
		return task;
	}

	public ICachedOutlineNode getRoot() {
		return root;
	}

	public IFile getFile() {
		return file;
	}
}
