package org.jmodelica.ide.compiler;

import java.util.ArrayList;

public class ModelicaASTRegistryUndoer {
	private static ModelicaASTRegistryUndoer instance;
	private ArrayList<ModificationJob> undoAddJobs = new ArrayList<ModificationJob>();
	private ArrayList<ModificationJob> undoRemoveJobs = new ArrayList<ModificationJob>();

	private ModelicaASTRegistryUndoer() {
	}

	public static synchronized ModelicaASTRegistryUndoer getInstance() {
		if (instance == null)
			instance = new ModelicaASTRegistryUndoer();
		return instance;
	}

	public synchronized void addUndoAddJob(ModificationJob job) {
		undoAddJobs.add(job);
	}

	public synchronized void addUndoRemoveJob(ModificationJob job) {
		undoRemoveJobs.add(job);
	}

	public synchronized void undoLastNodeAdd() {
		if (undoAddJobs.size() > 0)
			new ModelicaASTRegistryVisitor(undoAddJobs.remove(undoAddJobs
					.size() - 1));
	}

	public synchronized void undoLastNodeRemove() {
		if (undoRemoveJobs.size() > 0) {
			int changeSetId = undoRemoveJobs.get(undoRemoveJobs.size() - 1)
					.getChangeSetId();
			new ModelicaASTRegistryVisitor(undoRemoveJobs.remove(undoRemoveJobs
					.size() - 1));
			while (changeSetId != 0
					&& undoRemoveJobs.size() > 0
					&& undoRemoveJobs.get(undoRemoveJobs.size() - 1)
							.getChangeSetId() == changeSetId) {
				new ModelicaASTRegistryVisitor(
						undoRemoveJobs.remove(undoRemoveJobs.size() - 1));
			}
		}
	}
}
