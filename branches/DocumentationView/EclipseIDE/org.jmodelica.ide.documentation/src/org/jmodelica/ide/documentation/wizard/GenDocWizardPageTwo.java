package org.jmodelica.ide.documentation.wizard;

import javax.swing.JFileChooser;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.KeyEvent;
import org.eclipse.swt.events.KeyListener;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.layout.RowData;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Text;

public class GenDocWizardPageTwo extends WizardPage {
	private Text txtPath;
	private String path;

	protected GenDocWizardPageTwo(String pageName) {
		super(pageName);
		setTitle("Target");
		setDescription("Please specify where you want to save the documentation");
	}
	@Override
	public void createControl(Composite parent) {
		Composite composite = new Composite(parent, SWT.NONE);
		GridLayout layout = new GridLayout(2, false);
		layout.marginHeight = 0;
		composite.setLayout(layout);
		setControl(composite);
		txtPath = new Text(composite, SWT.NONE);
		//txtPath.setSize(300, txtPath.getSize().y*2);
		txtPath.setLayoutData(new GridData (SWT.FILL, SWT.CENTER, true, true));
		txtPath.addKeyListener(new KeyListener(){

			@Override
			public void keyPressed(KeyEvent e) {
			}

			@Override
			public void keyReleased(KeyEvent e) {
				if (!txtPath.getText().isEmpty()) {
					setPageComplete(true);

				}else{
					setPageComplete(false);
				}
			}
		});
		Button btnPath = new Button(composite, SWT.NONE);
		btnPath.setText("Browse..");
		setPageComplete(false);
		btnPath.addListener(SWT.Selection, new Listener(){

			@Override
			public void handleEvent(Event event) {
				JFileChooser fc = new JFileChooser();
				fc.setDialogTitle("Documentation generation - Specify directory");
				fc.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
				if (fc.showOpenDialog(null) == JFileChooser.APPROVE_OPTION){
					path = fc.getCurrentDirectory().getAbsolutePath().replace("\\","/") + "/" + fc.getSelectedFile().getName() + "/";
					txtPath.setText(path);
					setPageComplete(true);
				}
			}
		});

	}
	String getPath(){
		return path;
	}
}