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

public class IconRenderingWorker {
	
	private static IconRenderJob job = new IconRenderJob();
	
	/**
	 * Queues updating of the icon for an AST node.
	 * 
	 * @param viewer  the viewer that shows the node
	 * @param node    the node to update the icon for
	 */
	public static void addIcon(StructuredViewer viewer, ASTNode node) {
		if (!node.contentOutlineImageCalculated())
			job.addIcon(new IconInfo(viewer, node));
	}

	/**
	 * Queues updating of the icon for each element that is an AST node.
	 * 
	 * @param viewer    the viewer that shows the elements
	 * @param elements  the elements to update 
	 * @return  <code>elements</code>, for convenience
	 */
	public static Object[] addIcons(StructuredViewer viewer, Object[] elements) {
		if (elements != null)
			for (Object e : elements) 
				if (e instanceof ASTNode) 
					addIcon(viewer, (ASTNode) e);
		return elements;
	}

	private static class IconRenderJob extends Job {
		
		private static Object lock = new Object();

		private static final String JOB_NAME = "Render icons";
		
		private Queue<IconInfo> queue = new LinkedList<IconInfo>();
		private boolean running = false;

		public IconRenderJob() {
			super(JOB_NAME);
			setSystem(true);
		}

		protected IStatus run(IProgressMonitor monitor) {
			IconInfo info;
			synchronized (lock) {
				running = !queue.isEmpty();
			}
			while (running) {
				synchronized (lock) {
					info = queue.poll();
				}
				if (info != null) {
					synchronized (info.node.root()) {
						info.node.updateCachedIcon();
					}
					new IconUpdateJob(info).schedule();
				}
				synchronized (lock) {
					running = !queue.isEmpty();
				}
			}
			return Status.OK_STATUS;
		}
		
		public void addIcon(IconInfo icon) {
			boolean start = false;
			synchronized (lock) {
				start = !running;
				queue.add(icon);
			}
			if (start)
				schedule();
		}
		
	}
	
	private static class IconUpdateJob extends UIJob {

		private static final String JOB_NAME = "Update icons";
		
		private IconInfo info;

		public IconUpdateJob(IconInfo info) {
			super(JOB_NAME);
			setSystem(true);
			setPriority(INTERACTIVE);
			this.info = info;
		}

		public IStatus runInUIThread(IProgressMonitor monitor) {
			info.viewer.update(info.node, null);
			return Status.OK_STATUS;
		}
		
	}
	
	private static class IconInfo {
		
		public StructuredViewer viewer;
		public ASTNode node;
		
		public IconInfo(StructuredViewer viewer, ASTNode node) {
			super();
			this.viewer = viewer;
			this.node = node;
		}
		
	}
	
}
