package org.jmodelica.ide.sync.tasks;

import org.eclipse.core.resources.IFile;
import org.jmodelica.ide.sync.ASTRegModificationHandler;

/**
 * Used by for tasks that require the graphical editor to refresh cache.
 */
public abstract class AbstractModificationTask implements ITaskObject {
	protected IFile file;
	protected int undoActionId;

	protected AbstractModificationTask(IFile file, int undoActionId) {
		this.file = file;
		this.undoActionId = undoActionId;
	}

	@Override
	public void doJob() {
		new ASTRegModificationHandler(this);
	}

	@Override
	public int getJobPriority() {
		return ITaskObject.PRIORITY_HIGH;
	}

	@Override
	public int getListenerID() {
		return 0;
	}

	public IFile getFile() {
		return file;
	}

	public int getUndoActionId() {
		return undoActionId;
	}
}
