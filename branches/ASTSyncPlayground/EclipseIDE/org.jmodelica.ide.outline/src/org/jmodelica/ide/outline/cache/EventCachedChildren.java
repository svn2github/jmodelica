package org.jmodelica.ide.outline.cache;

import java.util.ArrayList;
import org.jastadd.ed.core.model.ASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jmodelica.ide.helpers.ICachedOutlineNode;
import org.jmodelica.ide.outline.OutlineUpdateWorker.ChildrenTask;

public class EventCachedChildren extends ASTChangeEvent {
	private ArrayList<ICachedOutlineNode> cachedChildren;
	private ChildrenTask task;

	public EventCachedChildren(ArrayList<ICachedOutlineNode> cachedChildren,
			ChildrenTask task) {
		super(IASTChangeEvent.CACHED_CHILDREN, IASTChangeEvent.FILE_LEVEL);
		this.cachedChildren = cachedChildren;
		this.task = task;
	}

	public ChildrenTask getTask() {
		return task;
	}

	public ArrayList<ICachedOutlineNode> getCachedChildren() {
		return cachedChildren;
	}
}