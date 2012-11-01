package org.jmodelica.ide.helpers;

import org.eclipse.jface.dialogs.IDialogConstants;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;

public class ExpandedMessageDialog extends MessageDialog {

	private static final int STYLE = SWT.MULTI | SWT.H_SCROLL | SWT.V_SCROLL | SWT.BORDER | SWT.WRAP;
	
	private String text;

	protected ExpandedMessageDialog(int kind, Shell shell, String title, String shortMessage, String longMessage) {
		super(shell, title, null, shortMessage, kind, new String[] { IDialogConstants.OK_LABEL }, kind);
		text = longMessage;
	}
	
	protected Control createCustomArea(Composite parent) {
        Text textArea = new Text(parent, STYLE);
        textArea.setText(text);
        GridData ld = new GridData(SWT.FILL, SWT.FILL, true, true);
        ld.heightHint = 300;
        ld.widthHint = 500;
		textArea.setLayoutData(ld);
		return textArea;
	}

	protected boolean isResizable() {
		return true;
	}

	public static int open(int kind, Shell shell, String title, String shortMessage, String longMessage) {
		ExpandedMessageDialog dialog = new ExpandedMessageDialog(kind, shell, title, shortMessage, longMessage);
		dialog.create();
		return dialog.open();
	}

}
