package org.jmodelica.ide.helpers;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.sync.tasks.ITaskObject;

public abstract class OutlineCacheJob implements ITaskObject {
	protected IASTChangeListener listener;
	protected IFile file;
	protected IOutlineCache cache;
	protected int listenerID;

	public OutlineCacheJob(IASTChangeListener listener, IFile file,
			IOutlineCache cache) {
		this.file = file;
		this.listener = listener;
		this.cache = cache;
		this.listenerID = cache.getListenerID();
	}

	@Override
	public int getJobPriority() {
		return ITaskObject.PRIORITY_HIGH;
	}

	@Override
	public int getJobType(){
		return ITaskObject.UPDATE;
	}
	
	@Override
	public int getListenerID() {
		return listenerID;
	}
}
