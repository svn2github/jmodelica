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
	private boolean expanded;

	/**
	 * A job that shows a dialog box. 
	 * 
	 * If <code>expanded</code> is <code>true</code>, then a custom message box that 
	 * has a scrollable text box is used instead. The message is shown in the text box. 
	 * If the message also contains at least two line feeds in a row, then the part 
	 * before that is shown above the text box instead.
	 * 
	 * @param title     the title of the dialog box
	 * @param message   the message to show
	 * @param kind      one of the kind constants from MessageDialog
	 * @param expanded  if <code>true</code>, use custom message box
	 *                  
	 */
	public ShowMessageJob(String title, String message, int kind, boolean expanded) {
		super(title);
		setPriority(INTERACTIVE);
		setSystem(true);
		this.message = message;
		this.kind = kind;
		this.expanded = expanded;
	}

	public IStatus runInUIThread(IProgressMonitor monitor) {
		final Display display = PlatformUI.getWorkbench().getDisplay();
		display.asyncExec(new Runnable() {
			public void run() {
				if (expanded) {
					String[] parts = message.split("\n{2,}", 2);
					if (parts.length < 2) 
						parts = new String[] { "", parts[0] };
					ExpandedMessageDialog.open(kind, display.getActiveShell(), getName(), parts[0], parts[1]);
				} else {
					MessageDialog.open(kind, display.getActiveShell(), getName(), message, SWT.NONE);
				}
			}
		});
		return Status.OK_STATUS;
	}

}
