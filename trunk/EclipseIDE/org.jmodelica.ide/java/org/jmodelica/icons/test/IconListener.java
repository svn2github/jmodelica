package org.jmodelica.icons.test;
//
//import java.lang.reflect.InvocationTargetException;
//
//import org.eclipse.core.runtime.IProgressMonitor;
//import org.eclipse.core.runtime.IStatus;
//import org.eclipse.core.runtime.Status;
//import org.eclipse.core.runtime.jobs.IJobChangeEvent;
//import org.eclipse.core.runtime.jobs.IJobChangeListener;
//import org.eclipse.core.runtime.jobs.Job;
//import org.eclipse.swt.widgets.Control;
//import org.eclipse.swt.widgets.Display;
//import org.eclipse.ui.IEditorInput;
//import org.eclipse.ui.IEditorPart;
//import org.eclipse.ui.IPartListener2;
//import org.eclipse.ui.IWorkbenchPartReference;
//import org.eclipse.ui.IWorkbenchWindow;
//import org.eclipse.ui.PlatformUI;
//import org.eclipse.ui.views.contentoutline.IContentOutlinePage;
//import org.eclipse.core.resources.IResource;
//import org.jmodelica.icons.IconLoader;
//import org.jmodelica.ide.editor.Editor;
//import org.jmodelica.ide.outline.OutlinePage;
//import org.eclipse.jface.operation.IRunnableContext;
//import org.eclipse.jface.viewers.TreeViewer;
//import org.eclipse.jface.window.ApplicationWindow;
//
//public class IconListener implements IPartListener2, IJobChangeListener {
//
//	private OutlinePage sourceOutlinePage;
//	private OutlinePage instanceOutlinePage;
//	
//	public void partBroughtToTop(IWorkbenchPartReference partRef) {
//		IEditorPart editorPart = partRef.getPage().getActiveEditor();
//		if (editorPart instanceof Editor) {
//			Editor editor = (Editor)editorPart;
//			/*OutlinePage*/ sourceOutlinePage = (OutlinePage)editor.getSourceOutlinePage(); 
//			/*OutlinePage*/ instanceOutlinePage = (OutlinePage)editor.getInstanceOutlinePage();
//			String path = IconLoader.getCurrentPath();
//			CreateIconsJob job = new CreateIconsJob("Create icons", path, 
//					sourceOutlinePage, instanceOutlinePage);
//			job.setSystem(true);
//			job.addJobChangeListener(this);
//			job.schedule();
//		}
//	}
//	
//	private static class CreateIconsJob extends Job {
//		
//		private String path;
//		//private OutlinePage sourceOutlinePage;
//		//private OutlinePage instanceOutlinePage;
//		
//		public CreateIconsJob(String name, String path, OutlinePage sourceOutlinePage,
//				OutlinePage instanceOutlinePage) {
//			super(name);
//			this.path = path;
//			//this.sourceOutlinePage = sourceOutlinePage;
//			//this.instanceOutlinePage = instanceOutlinePage;
//		}
//
//		@Override
//		protected IStatus run(IProgressMonitor monitor) {
//			IconLoader.readFile(path);
///*			Display.getDefault().syncExec(new Runnable() { 
//				public void run() { 
//					sourceOutlinePage.update();
//					instanceOutlinePage.update();
//				}
//			});
//*/
//			monitor.done();
//			return Status.OK_STATUS;
//		}
//	}
//
//	@Override
//	public void done(IJobChangeEvent arg0) {
//		if (arg0.getResult().equals(Status.OK_STATUS)) {
//			Display.getDefault().syncExec(new Runnable() { 
//				public void run() { 
//					sourceOutlinePage.update();
//					instanceOutlinePage.update();
//				}
//			});
//		}
//	}
//
//	@Override
//	public void partActivated(IWorkbenchPartReference arg0) {}
//
//	@Override
//	public void partClosed(IWorkbenchPartReference arg0) {}
//
//	@Override
//	public void partDeactivated(IWorkbenchPartReference arg0) {}
//
//	@Override
//	public void partHidden(IWorkbenchPartReference arg0) {}
//
//	@Override
//	public void partInputChanged(IWorkbenchPartReference arg0) {}
//
//	@Override
//	public void partOpened(IWorkbenchPartReference arg0) {}
//
//	@Override
//	public void partVisible(IWorkbenchPartReference arg0) {}
//	
//	@Override
//	public void aboutToRun(IJobChangeEvent arg0) {}
//
//	@Override
//	public void awake(IJobChangeEvent arg0) {}
//
//	@Override
//	public void running(IJobChangeEvent arg0) {}
//
//	@Override
//	public void scheduled(IJobChangeEvent arg0) {}
//
//	@Override
//	public void sleeping(IJobChangeEvent arg0) {}
//}
