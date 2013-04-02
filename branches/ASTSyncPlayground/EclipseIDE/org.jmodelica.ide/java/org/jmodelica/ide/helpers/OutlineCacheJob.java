package org.jmodelica.ide.helpers;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.compiler.IJobObject;

public abstract class OutlineCacheJob implements IJobObject {
	protected IASTChangeListener listener;
	protected IFile file;
	protected IOutlineCache cache;

	public OutlineCacheJob(IASTChangeListener listener, IFile file,
			IOutlineCache cache) {
		this.file = file;
		this.listener = listener;
		this.cache = cache;
	}

	public int getPriority() {
		return IJobObject.PRIORITY_HIGH;
	}

}
