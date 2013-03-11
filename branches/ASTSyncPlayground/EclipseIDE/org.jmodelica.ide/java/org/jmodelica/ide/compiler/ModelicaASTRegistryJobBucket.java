package org.jmodelica.ide.compiler;

import java.util.Comparator;
import java.util.PriorityQueue;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.swt.widgets.Display;

public class ModelicaASTRegistryJobBucket {
	private static ModelicaASTRegistryJobBucket jobBucket;
	private PriorityQueue<IJobObject> availableGraphicalJobs;
	private PriorityQueue<IJobObject> availableNonGraphicalJobs;

	private ModelicaASTRegistryJobBucket() {
		Comparator<IJobObject> comparator = new JobObjectComparator();
		availableGraphicalJobs = new PriorityQueue<IJobObject>(5, comparator);
		availableNonGraphicalJobs = new PriorityQueue<IJobObject>(5, comparator);
		// TODO larger initial capacity?
	}

	public static synchronized ModelicaASTRegistryJobBucket getInstance() {
		if (jobBucket == null)
			jobBucket = new ModelicaASTRegistryJobBucket();
		return jobBucket;
	}

	/**
	 * Add a job to the queue. A new background thread to handle one job from
	 * the queue will also automatically be created.
	 */
	public synchronized void addJob(IJobObject job) {
		if (job instanceof UpdateGraphicalJob) {
			// NOT a graphical job, does not need to run in U thread (maybe
			// misleading, refactor name?)
			availableNonGraphicalJobs.add(job);
			createNewNonGraphicalJobHandlerThread(Job.SHORT);
		} else if (job instanceof UpdateOutlineJob) {
			availableGraphicalJobs.add(job);
			createNewGraphicalJobHandlerThread(Job.DECORATE);
		} else if (job instanceof ModificationJob) {
			availableNonGraphicalJobs.add(job);
			createNewNonGraphicalJobHandlerThread(Job.SHORT);
		} // TODO texteditor
	}

	private void createNewNonGraphicalJobHandlerThread(int jobPriority) {
		Job job = new Job("NonGraphicalJob") {
			@Override
			protected IStatus run(IProgressMonitor monitor) {
				if (availableNonGraphicalJobs.size() > 0) {
					availableNonGraphicalJobs.poll().doJob();
				}
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
						if (availableGraphicalJobs.size() > 0) {
							availableGraphicalJobs.poll().doJob();
						}
					}
				});
				return Status.OK_STATUS;
			}
		};
		job.setPriority(jobPriority);
		job.schedule();
	}

	/**
	 * Get a job from the queue.
	 * 
	 * @return JobObject or NULL if no job available.
	 */
	protected synchronized IJobObject getJob() {
		while (availableGraphicalJobs.size() == 0) {
			try {
				wait();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		IJobObject job = null;
		if (availableGraphicalJobs.size() > 0)
			job = availableGraphicalJobs.poll();
		return job;
	}

	private class JobObjectComparator implements Comparator<IJobObject> {
		@Override
		public int compare(IJobObject x, IJobObject y) {
			if (x.getPriority() < y.getPriority()) {
				return -1;
			}
			if (x.getPriority() > y.getPriority()) {
				return 1;
			}
			return 0;
		}
	}
}
