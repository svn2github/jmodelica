package org.jmodelica.ide.compiler;

import java.util.Comparator;
import java.util.PriorityQueue;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.swt.widgets.Display;
import org.jmodelica.ide.outline.cache.OutlineCacheJob;

public class ModelicaASTRegistryJobBucket {
	private static ModelicaASTRegistryJobBucket jobBucket;
	private PriorityQueue<IJobObject> availableJobs;
	private boolean threadRunning = false;
	private IJobObject nextJob = null;

	private ModelicaASTRegistryJobBucket() {
		Comparator<IJobObject> comparator = new JobObjectComparator();
		availableJobs = new PriorityQueue<IJobObject>(5, comparator);
	}

	public static synchronized ModelicaASTRegistryJobBucket getInstance() {
		if (jobBucket == null)
			jobBucket = new ModelicaASTRegistryJobBucket();
		return jobBucket;
	}

	/**
	 * Add a job to the queue. A new jobhandler thread to handle one job from
	 * the queue will also automatically be created, if necessary.
	 */
	public synchronized void addJob(IJobObject job) {
		availableJobs.add(job);
		if (!threadRunning)
			startNewThread();
	}

	private void startNewThread() {
		System.out.println("Starting new thread! Jobs available: "
				+ availableJobs.size());
		threadRunning = true;
		nextJob = availableJobs.poll();
		if (nextJob instanceof UpdateGraphicalJob) {
			createNewNonGraphicalJobHandlerThread(Job.SHORT);
		} else if (nextJob instanceof UpdateOutlineJob) {
			createNewGraphicalJobHandlerThread(Job.SHORT);
		} else if (nextJob instanceof ModificationJob) {
			createNewNonGraphicalJobHandlerThread(Job.SHORT);
		} else if (nextJob instanceof OutlineCacheJob) {
			createNewNonGraphicalJobHandlerThread(Job.SHORT);
		}
	}

	protected synchronized void attendOwnFuneral() {
		if (availableJobs.size() > 0) {
			startNewThread();
		} else {
			threadRunning = false;
		}
	}

	private void createNewNonGraphicalJobHandlerThread(int jobPriority) {
		Job job = new Job("NonGraphicalJob") {
			@Override
			protected IStatus run(IProgressMonitor monitor) {
				nextJob.doJob();
				attendOwnFuneral();
				return Status.OK_STATUS;
			}
		};
		job.setPriority(jobPriority);
		job.schedule();
	}

	private void createNewGraphicalJobHandlerThread(int jobPriority) {
		Job job = new Job("GraphicalJob") {
			@Override
			protected IStatus run(IProgressMonitor monitor) {
				// Since we make changes to SWT/UI, we need this kind of
				// thread
				Display.getDefault().syncExec(new Runnable() {
					public void run() {
						nextJob.doJob();
						attendOwnFuneral();
					}
				});
				return Status.OK_STATUS;
			}
		};
		job.setPriority(jobPriority);
		job.schedule();
	}

	private class JobObjectComparator implements Comparator<IJobObject> {
		@Override
		public int compare(IJobObject x, IJobObject y) {
			if (x.getPriority() < y.getPriority()) {
				return 1;
			}
			if (x.getPriority() > y.getPriority()) {
				return -1;
			}
			return 0;
		}
	}
}
