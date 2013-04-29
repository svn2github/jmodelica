package org.jmodelica.ide.sync.tasks;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.ASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;

public class NotifyOutlineTask implements ITaskObject {
	private IASTChangeListener listener;
	private int outlineID;
	private int astChangeEventType;
	protected IFile file;

	public NotifyOutlineTask(IFile file, int astChangeEventType,
			IASTChangeListener listener, int outlineID) {
		if (file==null)
			System.err.println("UpdateOutlineJob file==NULL");
		this.listener = listener;
		this.outlineID = outlineID;
		this.astChangeEventType = astChangeEventType;
		this.file = file;
	}

	public int getJobPriority() {
		return ITaskObject.PRIORITY_LOW;
	}

	@Override
	public int getListenerID() {
		return outlineID;
	}

	@Override
	public void doJob() {
		//System.out.println("UpdateOutlineJob->doJob()");
		listener.astChanged(new ASTChangeEvent(file, astChangeEventType,
				IASTChangeEvent.FILE_LEVEL));
	}

	@Override
	public int getJobType() {
		return ITaskObject.UPDATE;
	}
}
