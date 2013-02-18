package org.jmodelica.ide.compiler;

import java.util.ArrayList;

import org.eclipse.swt.widgets.Display;

public class ModelicaASTRegistryJobBucket {
	private static ModelicaASTRegistryJobBucket jobBucket;
	private ArrayList<JobObject> availableJobs = new ArrayList<JobObject>();

	private ModelicaASTRegistryJobBucket() {
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
	public synchronized void addJob(JobObject job) {
		availableJobs.add(job);
		createNewJobHandlerThread();
	}

	/**
	 * Get a job from the queue.
	 * 
	 * @return JobObject or NULL.
	 */
	public synchronized JobObject getJob() {
		JobObject job = null;
		if (availableJobs.size() > 0) {
			job = availableJobs.remove(0);
		}
		return job;
	}

	private void createNewJobHandlerThread() {
		// Since we might make changes to SWT, we need this kind of thread
		Display.getDefault().syncExec(new Runnable() {
			public void run() {
				new ModelicaASTRegistryVisitor();
			}
		});
	}
}
