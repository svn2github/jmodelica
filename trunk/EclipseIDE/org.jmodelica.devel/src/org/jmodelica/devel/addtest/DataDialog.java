package org.jmodelica.devel.addtest;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.layout.RowLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Dialog;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;

public class DataDialog extends Dialog {

	private TestType type;
	private String result;
	private Shell shell;
	private Combo list;

	public DataDialog(Shell parent, TestType type) {
		super(parent);
		this.type = type;
	}
	
	public String open() {
		Shell parent = getParent();
		shell = new Shell(parent, SWT.DIALOG_TRIM | SWT.APPLICATION_MODAL);
		shell.setLayout(new RowLayout(SWT.HORIZONTAL));
		shell.setText("Generate " + type);
		
		Label text = new Label(shell, SWT.HORIZONTAL | SWT.LEFT);
		text.setText(type.dataDesc() + ":");
		list = new Combo(shell, SWT.DROP_DOWN);
		Button generate = new Button(shell, SWT.PUSH);
		generate.setText("Generate");
		generate.addListener(SWT.Selection, new GenerateListener());
		Button cancel = new Button(shell, SWT.PUSH);
		cancel.setText("Cancel");
		cancel.addListener(SWT.Selection, new CancelListener());
		
		result = null;
		shell.layout();
		shell.pack();
		shell.open();
		Display display = parent.getDisplay();
		while (!shell.isDisposed()) {
			if (!display.readAndDispatch()) display.sleep();
		}
		
		return result;
	}

	public class CancelListener implements Listener {

		public void handleEvent(Event event) {
			shell.close();
		}

	}

	public class GenerateListener implements Listener {

		public void handleEvent(Event event) {
			result = list.getText();
			shell.close();
		}

	}

}
