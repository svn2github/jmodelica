package org.jmodelica.ide.documentation.wizard;

import java.util.HashMap;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.eclipse.jface.wizard.Wizard;
import org.jmodelica.ide.documentation.sync.SaveFCDDocumentationTask;
import org.jmodelica.ide.sync.ASTPathPart;
import org.jmodelica.ide.sync.ASTRegTaskBucket;

public class GenDocWizard extends Wizard {
	private IFile file;
	private Stack<ASTPathPart> classASTPath;
	private GenDocWizardPage pageOne;
	public static final String PAGE_ONE = "PAGE_ONE";
	public static final String COMMENT = "comment";
	public static final String INFORMATION = "information";
	public static final String IMPORTS = "imports";
	public static final String EXTENSIONS = "extensions";
	public static final String COMPONENTS = "components";
	public static final String EQUATIONS = "equations";
	public static final String REVISIONS = "revisions";

	/**
	 * 
	 * @param fcd
	 *            The full class declaration that is at the root of what is to
	 *            be generated
	 * @param sourceRoot
	 *            The source root associated with the full class declaration.
	 *            Needed to determine restrictions for fcds and for class
	 *            lookups
	 * @param footer
	 *            Optional footer at the end of the HTML document
	 */
	public GenDocWizard(IFile file, Stack<ASTPathPart> classASTPath) {
		super();
		this.setWindowTitle("Documentation Generation");
		this.file = file;
		this.classASTPath = classASTPath;
	}

	/**
	 * Add an instance of GenDocWizardPageOne to the wizard
	 */
	public void addPages() {
		pageOne = new GenDocWizardPage(PAGE_ONE);
		addPage(pageOne);

	}

	/**
	 * Does the following: Collect the wizard information (inclusions and path).
	 * Generates documentation for the full class declaration Recursively
	 * generates documentation for all the classes in the full class
	 * declaration. Called when the user presses 'finish' in the wizard.
	 */
	public boolean performFinish() {
		String rootPath = ((GenDocWizardPage) getPage(GenDocWizard.PAGE_ONE))
				.getPath();
		HashMap<String, Boolean> checkBoxes = ((GenDocWizardPage) getPage(GenDocWizard.PAGE_ONE))
				.getCheckBoxes();
		SaveFCDDocumentationTask task = new SaveFCDDocumentationTask(file,
				rootPath, checkBoxes, classASTPath);
		ASTRegTaskBucket.getInstance().addTask(task);
		return true;
	}

	/**
	 * Returns whether the wizard can be finished, used to enable/disable the
	 * finish button
	 */
	@Override
	public boolean canFinish() {
		return getPage(PAGE_ONE).isPageComplete();
	}
}