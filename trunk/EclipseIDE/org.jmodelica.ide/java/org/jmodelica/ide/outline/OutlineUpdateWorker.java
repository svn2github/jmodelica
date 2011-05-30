package org.jmodelica.ide.outline;

import java.util.LinkedList;
import java.util.Queue;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.jface.viewers.StructuredViewer;
import org.eclipse.ui.progress.UIJob;
import org.jmodelica.modelica.compiler.ASTNode;

public class OutlineUpdateWorker {

	private static OutlineUpdateJob job = new OutlineUpdateJob();
	
	/**
	 * Queues updating of the icon for an AST node.
	 * 
	 * @param viewer  the viewer that shows the node
	 * @param node    the node to update the icon for
	 */
	public static void addIcon(StructuredViewer viewer, ASTNode node) {
		if (!node.contentOutlineImageCalculated())
			job.addTask(new IconTask(viewer, node));
	}

	/**
	 * Queues updating of the icon for each element that is an AST node.
	 * 
	 * @param viewer    the viewer that shows the elements
	 * @param elements  the elements to update the icons for
	 * @return  <code>elements</code>, for convenience
	 */
	public static Object[] addIcons(StructuredViewer viewer, Object[] elements) {
		if (elements != null)
			for (Object e : elements) 
				if (e instanceof ASTNode) 
					addIcon(viewer, (ASTNode) e);
		return elements;
	}
	
	/**
	 * Queues updating of the outline children for an AST node.
	 * 
	 * @param viewer  the viewer that shows the node
	 * @param node    the node to update the outline children for
	 */
	public static void addChildren(StructuredViewer viewer, ASTNode node) {
		if (!node.cachedOutlineChildrenIsCurrent())
			job.addTask(new ChildrenTask(viewer, node));
	}

	private static class OutlineUpdateJob extends Job {
		
		private static Object lock = new Object();

		private static final String JOB_NAME = "Calculate data for updating outlines";
		
		private Queue<Task> queue = new LinkedList<Task>();
		private boolean running = false;

		public OutlineUpdateJob() {
			super(JOB_NAME);
			setSystem(true);
		}

		protected IStatus run(IProgressMonitor monitor) {
			Task task;
			synchronized (lock) {
				running = !queue.isEmpty();
			}
			while (running) {
				synchronized (lock) {
					task = queue.poll();
				}
				if (task != null)
					task.run();
				synchronized (lock) {
					running = !queue.isEmpty();
				}
			}
			return Status.OK_STATUS;
		}
		
		public void addTask(Task task) {
			boolean start = false;
			synchronized (lock) {
				start = !running;
				queue.add(task);
			}
			if (start)
				schedule();
		}
		
	}
	
	private static class IconUpdateJob extends UIJob {

		private static final String JOB_NAME = "Update icons";
		
		private IconTask task;

		public IconUpdateJob(IconTask task) {
			super(JOB_NAME);
			setSystem(true);
			setPriority(INTERACTIVE);
			this.task = task;
		}

		public IStatus runInUIThread(IProgressMonitor monitor) {
			task.viewer.update(task.node, null);
			return Status.OK_STATUS;
		}
		
	}
	
	public static class ChildrenUpdateJob extends UIJob {

		private static final String JOB_NAME = "Update outline children";
		
		private ChildrenTask task;

		public ChildrenUpdateJob(ChildrenTask task) {
			super(JOB_NAME);
			setSystem(true);
			setPriority(INTERACTIVE);
			this.task = task;
		}

		public IStatus runInUIThread(IProgressMonitor monitor) {
			task.viewer.refresh(task.node);
			return Status.OK_STATUS;
		}

	}
	
	private static abstract class Task {
		
		public StructuredViewer viewer;
		public ASTNode node;
		
		public Task(StructuredViewer viewer, ASTNode node) {
			this.viewer = viewer;
			this.node = node;
		}

		public abstract void run();
		
	}
	
	private static class IconTask extends Task {
		
		public IconTask(StructuredViewer viewer, ASTNode node) {
			super(viewer, node);
		}

		public void run() {
			if (!node.contentOutlineImageCalculated()) {
				synchronized (node.state()) { 
					// Depends on ASTNode.state being static (if it isn't, use an object that is unique to the tree) 
					node.updateCachedIcon();
				}
				new IconUpdateJob(this).schedule();
			}
		}

		
	}
	
	private static class ChildrenTask extends Task {
		
		public ChildrenTask(StructuredViewer viewer, ASTNode node) {
			super(viewer, node);
		}

		public void run() {
			synchronized (node.state()) {
				// Depends on ASTNode.state being static (if it isn't, use an object that is unique to the tree) 
				node.updateOutlineCachedChildren();
			}
			new ChildrenUpdateJob(this).schedule();
		}
		
	}
	
}
