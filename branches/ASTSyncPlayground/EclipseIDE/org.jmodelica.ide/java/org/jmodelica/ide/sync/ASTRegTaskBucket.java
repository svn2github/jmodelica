package org.jmodelica.ide.sync;

import java.util.Comparator;
import java.util.PriorityQueue;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.swt.widgets.Display;
import org.jmodelica.ide.helpers.OutlineCacheJob;
import org.jmodelica.ide.sync.tasks.AbstractAestheticModificationTask;
import org.jmodelica.ide.sync.tasks.AbstractModificationTask;
import org.jmodelica.ide.sync.tasks.CompileFileTask;
import org.jmodelica.ide.sync.tasks.ITaskObject;
import org.jmodelica.ide.sync.tasks.NotifyGraphicalTask;
import org.jmodelica.ide.sync.tasks.NotifyOutlineTask;

public class ASTRegTaskBucket {
	private static ASTRegTaskBucket taskBucket;
	private PriorityQueue<ITaskObject> availableTasks;
	private boolean threadRunning = false;
	private ITaskObject nextTask = null;

	private ASTRegTaskBucket() {
		Comparator<ITaskObject> comparator = new JobObjectComparator();
		availableTasks = new PriorityQueue<ITaskObject>(5, comparator);
	}

	public static synchronized ASTRegTaskBucket getInstance() {
		if (taskBucket == null)
			taskBucket = new ASTRegTaskBucket();
		return taskBucket;
	}

	/**
	 * Add a job to the queue. A new task handler thread to handle one job from
	 * the queue will also automatically be created, if necessary.
	 */
	public synchronized void addTask(ITaskObject task) {
		if (task instanceof NotifyGraphicalTask
				|| task instanceof NotifyOutlineTask) {
			boolean contains = false;
			for (ITaskObject jobObj : availableTasks) {
				if (jobObj.getListenerID() == task.getListenerID())
					contains = true;
			}
			if (!contains)
				availableTasks.add(task);
		//	if (contains)
		//		System.err
		//				.println("DIDNT ADD UPDATE JOB TO QUEUE, ALREADY EXISTED IDENTICAL...");
		} else {
			availableTasks.add(task);
		}
		if (!threadRunning)
			startNewThread();
	}

	private void startNewThread() {
		// System.out.println("Starting new thread! Jobs available: "
		// + availableJobs.size());
		threadRunning = true;
		nextTask = availableTasks.poll();
		// System.out.println("DOING JOB, prio: "+nextJob.getJobPriority()+", listenerID: "+nextJob.getListenerID());
		if (nextTask instanceof NotifyGraphicalTask) {
			startBackgroundTaskHandler(Job.SHORT);
		} else if (nextTask instanceof NotifyOutlineTask) {
			startUISafeTaskHandler(Job.SHORT);
		} else if (nextTask instanceof AbstractModificationTask) {
			startBackgroundTaskHandler(Job.SHORT);
		} else if (nextTask instanceof OutlineCacheJob) {
			startBackgroundTaskHandler(Job.SHORT);
		} else if (nextTask instanceof CompileFileTask) {
			startBackgroundTaskHandler(Job.BUILD);
		} else if (nextTask instanceof AbstractAestheticModificationTask) {
			startBackgroundTaskHandler(Job.SHORT);
		}
	}

	protected synchronized void attendOwnFuneral() {
		if (availableTasks.size() > 0) {
			startNewThread();
		} else {
			threadRunning = false;
		}
	}

	private void startBackgroundTaskHandler(int jobPriority) {
		Job job = new Job("NonGraphicalJob") {
			@Override
			protected IStatus run(IProgressMonitor monitor) {
				try {
					nextTask.doJob();
				} catch (Exception e) {
					System.err
							.println("Background task handler thread generated exception! "
									+ e.getMessage());
				} finally {
					attendOwnFuneral();
				}
				return Status.OK_STATUS;
			}
		};
		job.setPriority(jobPriority);
		job.schedule();
	}

	private void startUISafeTaskHandler(int jobPriority) {
		Job job = new Job("GraphicalJob") {
			@Override
			protected IStatus run(IProgressMonitor monitor) {
				// Since we make changes to SWT/UI, we need this kind of
				// thread
				Display.getDefault().syncExec(new Runnable() {
					public void run() {
						try {
							nextTask.doJob();
						} catch (Exception e) {
							System.err
									.println("UI safe task handler thread generated exception! "
											+ e.getMessage());
						} finally {
							attendOwnFuneral();
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
	 * Orders task's in priority order.
	 */
	private class JobObjectComparator implements Comparator<ITaskObject> {
		@Override
		public int compare(ITaskObject x, ITaskObject y) {
			if (x.getJobPriority() < y.getJobPriority()) {
				return 1;
			}
			if (x.getJobPriority() > y.getJobPriority()) {
				return -1;
			}
			return 0;
		}
	}
}
