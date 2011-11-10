package org.jmodelica.ide.outline;

import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Map;
import java.util.Queue;
import java.util.Set;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.jface.viewers.StructuredViewer;
import org.eclipse.jface.viewers.TreePath;
import org.eclipse.jface.viewers.TreeSelection;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.ui.progress.UIJob;
import org.jmodelica.modelica.compiler.ASTNode;

public class OutlineUpdateWorker {

	private static OutlineUpdateJob job = new OutlineUpdateJob();
	private static Map<ASTNode, Set<ChildrenUpdatedListener>> childrenUpdatedListenerMap = 
		new HashMap<ASTNode, Set<ChildrenUpdatedListener>>();
	
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

	/**
	 * Add a listener to be notified when the list of outline children 
	 * for the specified node is updated. Since this normally only happens 
	 * once for each node, the listener is removed before it is notified.
	 *  
	 * @param node      the node to add the listener for
	 * @param listener  the listener to add
	 */
	public static void addChildrenUpdatedListener(ASTNode node, ChildrenUpdatedListener listener) {
		Set<ChildrenUpdatedListener> listeners = childrenUpdatedListenerMap.get(node);
		if (listeners == null) {
			listeners = new HashSet<ChildrenUpdatedListener>();
			childrenUpdatedListenerMap.put(node, listeners);
		}
		listeners.add(listener);
	}

	/**
	 * Remove a listener that was to be notified when the list of outline 
	 * children for the specified node is updated. If the listener isn't 
	 * registered for the given node, nothing happens.
	 *  
	 * @param node      the node to remove the listener for
	 * @param listener  the listener to remove
	 */
	public static void removeChildrenUpdatedListener(ASTNode node, ChildrenUpdatedListener listener) {
		Set<ChildrenUpdatedListener> listeners = childrenUpdatedListenerMap.get(node);
		if (listeners != null) {
			listeners.remove(listener);
			if (listeners.isEmpty())
				childrenUpdatedListenerMap.remove(listeners);
		}
	}

	/**
	 * Expand tree in <code>page</code> down to the node given by <code>path</code>. 
	 * If any nodes along the path aren't loaded yet, expansion will pause until they are.
	 * 
	 * @param page    the page that contains the path
	 * @param viewer  the viewer that shows the node
	 * @param path    the path from the root (the tree root, not the AST root) to the node to select 
	 */
	public static void expandAndSelect(OutlinePage page, TreeViewer viewer, TreePath path) {
		new ExpandAndSelectWorker(page, viewer, path).work();
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
			ASTNode node = task.node;
			task.viewer.refresh(node);
			Set<ChildrenUpdatedListener> listeners = childrenUpdatedListenerMap.get(node);
			if (listeners != null)
				for (ChildrenUpdatedListener listener : listeners)
					listener.childrenUpdated(node);
			childrenUpdatedListenerMap.remove(node);
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
				try {
					synchronized (node.state()) { 
						// Depends on ASTNode.state being static (if it isn't, use an object that is unique to the tree)
						node.updateCachedIcon();
					}
					new IconUpdateJob(this).schedule();
				} catch (Throwable t) {
					// Don't let anything be thrown past here
					t.printStackTrace();
					return;
				}
			}
		}

		
	}
	
	private static class ChildrenTask extends Task {
		
		public ChildrenTask(StructuredViewer viewer, ASTNode node) {
			super(viewer, node);
		}

		public void run() {
			try {
				synchronized (node.state()) {
					// Depends on ASTNode.state being static (if it isn't, use an object that is unique to the tree) 
					node.updateOutlineCachedChildren();
				}
				new ChildrenUpdateJob(this).schedule();
			} catch (Throwable t) {
				// Don't let anything be thrown past here
				t.printStackTrace();
				return;
			}
		}
		
	}
	
	private interface ChildrenUpdatedListener {
		
		public void childrenUpdated(ASTNode node);
		
	}

	private static class ExpandAndSelectWorker implements ChildrenUpdatedListener {

		private OutlinePage page;
		private TreePath path;
		private TreeViewer viewer;
		private int i;

		public ExpandAndSelectWorker(OutlinePage page, TreeViewer viewer, TreePath path) {
			this.page = page;
			this.path = path;
			this.viewer = viewer;
			i = 1;
		}

		public void work() {
			if (i < path.getSegmentCount()) {
				if (viewer.testFindItem(path.getSegment(i)) == null) {
					Object parent = path.getSegment(i - 1);
					i++;
					if (parent instanceof ASTNode) {
						ASTNode parentNode = (ASTNode) parent;
						addChildrenUpdatedListener(parentNode, this);
						addChildren(viewer, parentNode);
					}
				} else {
					i++;
					work();
				}
			} else {
				page.select(new TreeSelection(path));
			}
		}

		public void childrenUpdated(ASTNode node) {
			viewer.expandToLevel(node, 1);
			work();
		}

	}
	
}
