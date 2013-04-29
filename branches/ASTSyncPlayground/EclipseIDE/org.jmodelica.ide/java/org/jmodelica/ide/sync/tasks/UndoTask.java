package org.jmodelica.ide.sync.tasks;

public class UndoTask extends AbstractModificationTask {
	private int undoType;

	public UndoTask(int undoType, int undoActionId) {
		super(null, undoActionId);
		this.undoType = undoType;
	}

	@Override
	public int getJobType() {
		return undoType;
	}
}
