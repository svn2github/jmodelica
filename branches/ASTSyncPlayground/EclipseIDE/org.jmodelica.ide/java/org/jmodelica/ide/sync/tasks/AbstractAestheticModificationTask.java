package org.jmodelica.ide.sync.tasks;


/**
 * Used by for tasks that do not require the graphical editor to refresh cache.
 */
public abstract class AbstractAestheticModificationTask implements ITaskObject {

	@Override
	public abstract void doJob();

	@Override
	public int getJobType() {
		return ITaskObject.GRAPHICAL_AESTHETIC;
	}

	@Override
	public int getJobPriority() {
		return ITaskObject.PRIORITY_LOW;
	}

	@Override
	public int getListenerID() {
		return 0;
	}
}
