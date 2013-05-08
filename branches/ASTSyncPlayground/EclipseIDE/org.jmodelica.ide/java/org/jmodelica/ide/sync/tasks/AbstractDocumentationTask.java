package org.jmodelica.ide.sync.tasks;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeListener;

public abstract class AbstractDocumentationTask implements ITaskObject {
	protected IASTChangeListener myListener;
	protected IFile file;

	public AbstractDocumentationTask(IFile file, IASTChangeListener myListener) {
		this.myListener = myListener;
		this.file = file;
	}

	@Override
	public abstract void doJob();

	@Override
	public int getJobType() {
		return ITaskObject.GENERATE_DOCUMENTATION;
	}

	@Override
	public int getJobPriority() {
		return ITaskObject.PRIORITY_MEDIUM;
	}

	@Override
	public int getListenerID() {
		return 0;
	}
}