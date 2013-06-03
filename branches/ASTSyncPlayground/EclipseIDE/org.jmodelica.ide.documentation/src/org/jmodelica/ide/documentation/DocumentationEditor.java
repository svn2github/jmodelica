package org.jmodelica.ide.documentation;

import java.io.ByteArrayInputStream;
import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.Assert;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.SafeRunner;
import org.eclipse.jface.dialogs.IDialogConstants;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.util.SafeRunnable;
import org.eclipse.swt.SWT;
import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorSite;
import org.eclipse.ui.ISaveablePart2;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.part.EditorPart;
import org.eclipse.ui.services.ISourceProviderService;
import org.jastadd.ed.core.model.IASTPathPart;
import org.jmodelica.ide.documentation.commands.NavigationProvider;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class DocumentationEditor extends EditorPart implements ISaveablePart2 {

	private Label contents;
	private Browser browser;
	private DocumentationEditorInput input;
	private BrowserContent browserContent;
	private boolean isDirty;

	@Override
	public void createPartControl(Composite parent) {
		ISourceProviderService sourceProviderService = (ISourceProviderService) this
				.getSite().getWorkbenchWindow()
				.getService(ISourceProviderService.class);
		NavigationProvider navProv = (NavigationProvider) sourceProviderService
				.getSourceProvider(NavigationProvider.NAVIGATION_FORWARD);
		browser = new Browser(parent, SWT.NONE);
		browserContent = new BrowserContent(this, input.getClassASTPath(),
				input.getFile(), browser, navProv, this.input.getGenDoc());
	}

	/**
	 * Navigate to the previous page in the browser history
	 * 
	 * @return whether the action was successful
	 */
	public boolean back() {
		return browserContent.back();
	}

	/**
	 * Navigate to the next page in the browser history
	 * 
	 * @return whether the action was successful
	 */
	public boolean forward() {
		return browserContent.forward();
	}

	@Override
	protected void setInput(IEditorInput input) {
		super.setInput(input);
		Assert.isLegal(input instanceof DocumentationEditorInput,
				"The viewer only support opening Modelica classes.");
		this.input = (DocumentationEditorInput) input;
		setPartName(input.getName());
	}

	@Override
	public void doSave(final IProgressMonitor monitor) {
		SafeRunner.run(new SafeRunnable() {
			public void run() throws Exception {
				IFile file = input.getFile();
				StoredDefinition def = ModelicaASTRegistry.getInstance()
						.getLatestDef(file);
				file.setContents(new ByteArrayInputStream(def
						.prettyPrintFormatted().getBytes()), false, true,
						monitor);
			}
		});
	}

	@Override
	public void doSaveAs() {
	}

	@Override
	public void init(IEditorSite site, IEditorInput input)
			throws PartInitException {
		setSite(site);
		setInput(input);
	}

	@Override
	public boolean isDirty() {
		return isDirty;
	}

	public void setDirty(boolean isDirty) {
		this.isDirty = isDirty;
		this.firePropertyChange(ISaveablePart2.PROP_DIRTY);
	}

	@Override
	public boolean isSaveAsAllowed() {
		return false;
	}

	@Override
	public void setFocus() {
		if (contents != null)
			contents.setFocus();
	}

	public String getCurrentClassIdentifier() {
		return browserContent.getCurrentClassIdentifier();
	}

	/**
	 * Generate documentation for the full class declaration elem
	 * 
	 * @param fcd
	 */
	public void generateDocumentation(IFile file,
			Stack<IASTPathPart> classASTPath) {
		browserContent.generateDocumentation(file, classASTPath);
	}

	/**
	 * Generate documentation for the full class declaration elem
	 * 
	 * @param fcd
	 */
	public void generateDocumentation(String filePath,
			Stack<IASTPathPart> classASTPath) {
		IFile aFile = input.getFileFromPath(filePath);
		browserContent.generateDocumentation(aFile, classASTPath);
	}

	@Override
	public int promptToSaveOnClose() {
		if (!browserContent.isDirty())
			return ISaveablePart2.YES;
		MessageDialog dialog = new MessageDialog(getEditorSite().getShell(),
				"Save Resources", null, "'"
						+ "'Current page has been modified. Save changes?",
				MessageDialog.QUESTION, new String[] {
						IDialogConstants.YES_LABEL, IDialogConstants.NO_LABEL,
						IDialogConstants.CANCEL_LABEL }, 0);
		int dialogResults = dialog.open();
		if (dialogResults == 0) {
			if (browserContent.save()) {
				browserContent.undoChanges();
				return ISaveablePart2.YES;
			} else {
				return ISaveablePart2.CANCEL;
			}
		} else if (dialogResults == 1) {
			browserContent.undoChanges();
			return ISaveablePart2.NO;
		} else {
			return ISaveablePart2.CANCEL;
		}
	}
}