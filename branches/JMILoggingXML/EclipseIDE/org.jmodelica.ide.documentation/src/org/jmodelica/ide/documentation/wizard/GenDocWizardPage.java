package org.jmodelica.ide.documentation.wizard;

import java.util.HashMap;
import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.KeyEvent;
import org.eclipse.swt.events.KeyListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.DirectoryDialog;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;
public class GenDocWizardPage extends WizardPage {

	private HashMap<String, Boolean> checkBoxes;
	private Button chkComment;
	private Button chkInformation;
	private Button chkImport;
	private Button chkExtension;
	private Button chkComponents;
	private Button chkEquations;
	private Button chkRevisions;
	private Text txtPath;
	private Label lblPath;
	private Button btnPath;
	private String path;
	private Display display;
	
	/**
	 * A Eclipse wizard page that handles generation of documentation for a given library.
	 * @param pageName ID for the page
	 */
	protected GenDocWizardPage(String pageName) {
		super(pageName);
		setTitle("Inclusions");
		setDescription("Please specify what you want to include in the documentation, and where you want it saved.");
		checkBoxes = new HashMap<String, Boolean>();
	}
	
	/**
	 * Sets up the GUI - inclusions and path
	 */
	@Override
	public void createControl(Composite parent){ 
		this.display = parent.getDisplay();
		Composite main = new Composite(parent, SWT.NONE);
		GridLayout mainLayout = new GridLayout();
		mainLayout.numColumns = 1;
		main.setLayout(mainLayout);
		GridData contentGridData = new GridData(SWT.LEFT, SWT.TOP, false, true, 1, 1);
		GridData pathGridData = new GridData(SWT.LEFT, SWT.BOTTOM, false, true, 1, 1);
		Composite compositeContent = new Composite(main, SWT.TOP);
		compositeContent.setLayoutData(contentGridData);
		Composite compositePath = new Composite(main, SWT.BOTTOM);
		compositePath.setLayoutData(pathGridData);
		GridLayout layoutContent = new GridLayout();
		layoutContent.numColumns = 1;
		GridLayout layoutPath = new GridLayout();
		layoutPath.numColumns = 3;
		compositeContent.setLayout(layoutContent);
		compositePath.setLayout(layoutPath);
		setControl(main);
		chkComment = new Button(compositeContent, SWT.CHECK);
		chkComment.setText("Comment");
		chkComment.setSelection(true);
		chkInformation = new Button(compositeContent, SWT.CHECK);
		chkInformation.setText("Information");
		chkInformation.setSelection(true);
		chkImport = new Button(compositeContent, SWT.CHECK);
		chkImport.setText("Import");
		chkImport.setSelection(true);
		chkExtension = new Button(compositeContent, SWT.CHECK);
		chkExtension.setText("Extension");
		chkExtension.setSelection(true);
		chkComponents = new Button(compositeContent, SWT.CHECK);
		chkComponents.setText("Components");
		chkComponents.setSelection(true);
		chkEquations = new Button(compositeContent, SWT.CHECK);
		chkEquations.setText("Equations");
		chkRevisions = new Button(compositeContent, SWT.CHECK);
		chkRevisions.setText("Revisions");
		chkRevisions.setSelection(true);
		
		lblPath = new Label(compositePath, SWT.FILL);
		lblPath.setText("Path:");
		txtPath = new Text(compositePath, SWT.BORDER);
		GridData txtPathGridData = new GridData (SWT.FILL, SWT.CENTER, true, true);
		txtPathGridData.widthHint = 410;
		txtPath.setLayoutData(txtPathGridData);
		txtPath.addKeyListener(new KeyListener(){

			@Override
			public void keyPressed(KeyEvent e) {
			}

			@Override
			public void keyReleased(KeyEvent e) {
				if (!txtPath.getText().isEmpty()) {
					path = txtPath.getText().replace("\\", "/");
					if (!path.endsWith("/")) path += "/";
					setPageComplete(true);

				}else{
					setPageComplete(false);
				}
			}
		});
		btnPath = new Button(compositePath, SWT.NONE);
		btnPath.setText("Browse..");
		btnPath.addListener(SWT.Selection, new Listener(){
			
			@Override
			public void handleEvent(Event event){ //Creates a SWT DirectoryDialog (file chooser)
				  Shell shell = new Shell(display);
				DirectoryDialog dialog = new DirectoryDialog(shell);
				dialog.setMessage("Please specify target directory for the documentation.");
				dialog.setText("Documentation Generation");
				String s = dialog.open();
				String platform = SWT.getPlatform();
				dialog.setFilterPath (platform.equals("win32") || platform.equals("wpf") ? "c:\\" : "/");
				if (s != null && !s.equals("")){
					txtPath.setText(s);
					path = s.replace("\\", "/");
					if (!path.endsWith("/")) path += "/";
					setPageComplete(true);
				}
			}
		});
		setTitle("Content and target");
		setPageComplete(false);
	}
	
	/**
	 * 
	 * @return a HashMap containing all the values from the check boxes.
	 */
	public HashMap<String, Boolean> getCheckBoxes() {
		checkBoxes.put(GenDocWizard.COMMENT, chkComment.getSelection());
		checkBoxes.put(GenDocWizard.INFORMATION, chkInformation.getSelection());
		checkBoxes.put(GenDocWizard.IMPORTS, chkImport.getSelection());
		checkBoxes.put(GenDocWizard.EXTENSIONS, chkExtension.getSelection());
		checkBoxes.put(GenDocWizard.COMPONENTS, chkComponents.getSelection());
		checkBoxes.put(GenDocWizard.EQUATIONS, chkEquations.getSelection());
		checkBoxes.put(GenDocWizard.REVISIONS, chkRevisions.getSelection());
		return checkBoxes;
	}
	
	String getPath(){
		return path;
	}
}
