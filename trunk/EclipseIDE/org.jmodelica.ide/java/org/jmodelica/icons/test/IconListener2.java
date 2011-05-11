package org.jmodelica.icons.test;
/*
import java.lang.reflect.InvocationTargetException;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.IJobChangeEvent;
import org.eclipse.core.runtime.jobs.IJobChangeListener;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IPartListener2;
import org.eclipse.ui.IWorkbenchPartReference;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.views.contentoutline.IContentOutlinePage;
import org.eclipse.core.resources.IResource;
import org.jmodelica.icons.IconLoader;
import org.jmodelica.ide.editor.Editor;
import org.jmodelica.ide.outline.OutlinePage;
import org.eclipse.jface.operation.IRunnableContext;
import org.eclipse.jface.window.ApplicationWindow;

public class IconListener2 implements IPartListener2 {

	public void partBroughtToTop(IWorkbenchPartReference partRef) {
		IWorkbenchWindow window = PlatformUI.getWorkbench().getActiveWorkbenchWindow();
		IEditorPart editorPart = partRef.getPage().getActiveEditor();
		if (editorPart instanceof Editor) {
			String path = IconLoader.getCurrentPath();
			try {
				window.run(true, false, new CreateIconsOperation(path));
			} catch (InvocationTargetException e) {} 
			catch (InterruptedException e) {}
		}
	}
	
	@Override
	public void partActivated(IWorkbenchPartReference arg0) {}

	@Override
	public void partClosed(IWorkbenchPartReference arg0) {}

	@Override
	public void partDeactivated(IWorkbenchPartReference arg0) {}

	@Override
	public void partHidden(IWorkbenchPartReference arg0) {}

	@Override
	public void partInputChanged(IWorkbenchPartReference arg0) {}

	@Override
	public void partOpened(IWorkbenchPartReference arg0) {}

	@Override
	public void partVisible(IWorkbenchPartReference arg0) {}
}
*/