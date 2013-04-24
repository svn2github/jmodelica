package org.jmodelica.ide.helpers;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.compiler.IJobObject;

public abstract class OutlineCacheJob implements IJobObject {
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
	public int getPriority() {
		return IJobObject.PRIORITY_HIGH;
	}

	@Override
	public int getListenerID() {
		return listenerID;
	}
}
