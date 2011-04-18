package org.jmodelica.ide.helpers;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.progress.UIJob;

public class ShowMessageJob extends UIJob {

	private String message;
	private int kind;

	/**
	 * A job that shows a dialog box. 
	 * Arguments are same as corresponding argument to MessageDialog.open().
	 */
	public ShowMessageJob(String title, String message, int kind) {
		super(title);
		setPriority(INTERACTIVE);
		setSystem(true);
		this.message = message;
		this.kind = kind;
	}

	public IStatus runInUIThread(IProgressMonitor monitor) {
		final Display display = PlatformUI.getWorkbench().getDisplay();
		display.asyncExec(new Runnable() {
			public void run() {
				MessageDialog.open(kind, display.getActiveShell(), getName(), message, SWT.NONE);
			}
		});
		return Status.OK_STATUS;
	}

}
