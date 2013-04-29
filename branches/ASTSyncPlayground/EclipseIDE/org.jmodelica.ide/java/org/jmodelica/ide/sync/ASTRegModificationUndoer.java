package org.jmodelica.ide.sync;

import java.util.ArrayList;

import org.jmodelica.ide.sync.tasks.AbstractModificationTask;

public class ASTRegModificationUndoer {
	private static ASTRegModificationUndoer instance;
	private ArrayList<AbstractModificationTask> undoAddJobs = new ArrayList<AbstractModificationTask>();
	private ArrayList<AbstractModificationTask> undoRemoveJobs = new ArrayList<AbstractModificationTask>();

	private ASTRegModificationUndoer() {
	}

	public static synchronized ASTRegModificationUndoer getInstance() {
		if (instance == null)
			instance = new ASTRegModificationUndoer();
		return instance;
	}

	public synchronized void addUndoAddJob(AbstractModificationTask job) {
		undoAddJobs.add(job);
	}

	public synchronized void addUndoRemoveJob(AbstractModificationTask job) {
		undoRemoveJobs.add(job);
	}

	public synchronized void undoLastNodeAdd(int actionId) {
		ArrayList<AbstractModificationTask> jobs = getJobs(actionId,
				undoAddJobs);
		for (int i = 0; i < jobs.size(); i++)
			new ASTRegModificationHandler(jobs.get(i));
	}

	private ArrayList<AbstractModificationTask> getJobs(int actionId,
			ArrayList<AbstractModificationTask> undoJobs) {
		ArrayList<AbstractModificationTask> toReturn = new ArrayList<AbstractModificationTask>();
		if (undoJobs.size() > 0) {
			for (int i = undoJobs.size() - 1; i >= 0; i--) {
				if (undoJobs.get(i).getUndoActionId() == actionId) {
					toReturn.add(undoJobs.remove(i));
				}
			}
		}
		return toReturn;
	}

	public synchronized void undoLastNodeRemove(int actionId) {
		ArrayList<AbstractModificationTask> jobs = getJobs(actionId,
				undoRemoveJobs);
		for (int i = 0; i < jobs.size(); i++)
			new ASTRegModificationHandler(jobs.get(i));
	}
}
