package org.jmodelica.ide.compiler;

import java.util.Comparator;
import java.util.PriorityQueue;

import org.eclipse.swt.widgets.Display;

public class ModelicaASTRegistryJobBucket {
	private static ModelicaASTRegistryJobBucket jobBucket;
	private PriorityQueue<IJobObject> availableJobs;

	private ModelicaASTRegistryJobBucket() {
		Comparator<IJobObject> comparator = new JobObjectComparator();
		availableJobs = new PriorityQueue<IJobObject>(5, comparator);
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
		availableJobs.add(job);
		createNewJobHandlerThread();
	}

	/**
	 * Get a job from the queue.
	 * 
	 * @return JobObject or NULL if no job available.
	 */
	protected synchronized IJobObject getJob() {
		while (availableJobs.size() == 0) {
			try {
				wait();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		IJobObject job = null;
		if (availableJobs.size() > 0)
			job = availableJobs.poll();
		return job;
	}

	private void createNewJobHandlerThread() {
		// Since we might make changes to SWT, we need this kind of thread
		Display.getDefault().syncExec(new Runnable() {
			public void run() {
				IJobObject job = getJob();
				if (job != null)
					job.doJob(); // TODO not display exec?
			}
		});
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
