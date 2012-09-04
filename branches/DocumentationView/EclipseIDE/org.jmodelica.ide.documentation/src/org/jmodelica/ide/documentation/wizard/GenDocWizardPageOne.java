package org.jmodelica.ide.documentation.wizard;

import java.util.HashMap;

import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
public class GenDocWizardPageOne extends WizardPage {

	private HashMap<String, Boolean> checkBoxes;
	public static final String COMMENT = "comment";
	public static final String INFORMATION = "information";
	public static final String IMPORTS = "imports";
	public static final String EXTENSIONS = "extensions";
	public static final String COMPONENTS = "components";
	public static final String EQUATIONS = "equations";
	public static final String REVISIONS = "revisions";
	private Button chkComment;
	private Button chkInformation;
	private Button chkImport;
	private Button chkExtension;
	private Button chkComponents;
	private Button chkEquations;
	private Button chkRevisions;
	
	protected GenDocWizardPageOne(String pageName) {
		super(pageName);
		setTitle("Inclusions");
		setDescription("Please specify what you want to include in the documentation");
		checkBoxes = new HashMap<String, Boolean>();
	}
	@Override
	public void createControl(Composite parent){ 
		Composite composite = new Composite(parent, SWT.NONE);
		GridLayout layout = new GridLayout();
		layout.numColumns = 1;
		composite.setLayout(layout);
		setControl(composite);
		chkComment = new Button(composite, SWT.CHECK);
		chkComment.setText("Comment");
		chkComment.setSelection(true);
		chkInformation = new Button(composite, SWT.CHECK);
		chkInformation.setText("Information");
		chkInformation.setSelection(true);
		chkImport = new Button(composite, SWT.CHECK);
		chkImport.setText("Import");
		chkImport.setSelection(true);
		chkExtension = new Button(composite, SWT.CHECK);
		chkExtension.setText("Extension");
		chkExtension.setSelection(true);
		chkComponents = new Button(composite, SWT.CHECK);
		chkComponents.setText("Components");
		chkComponents.setSelection(true);
		chkEquations = new Button(composite, SWT.CHECK);
		chkEquations.setText("Equations");
		chkRevisions = new Button(composite, SWT.CHECK);
		chkRevisions.setText("Revisions");
		chkRevisions.setSelection(true);
		setPageComplete(true);
	}
	public HashMap<String, Boolean> getCheckBoxes() {
		checkBoxes.put(COMMENT, chkComment.getSelection());
		checkBoxes.put(INFORMATION, chkInformation.getSelection());
		checkBoxes.put(IMPORTS, chkImport.getSelection());
		checkBoxes.put(EXTENSIONS, chkExtension.getSelection());
		checkBoxes.put(COMPONENTS, chkComponents.getSelection());
		checkBoxes.put(EQUATIONS, chkEquations.getSelection());
		checkBoxes.put(REVISIONS, chkRevisions.getSelection());
		return checkBoxes;
	}
}
