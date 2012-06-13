package org.jmodelica.ide.documentation;

import java.io.ByteArrayInputStream;

import org.eclipse.core.runtime.Assert;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.SafeRunner;
import org.eclipse.jface.util.SafeRunnable;
import org.eclipse.swt.SWT;
import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorSite;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.part.EditorPart;
import org.eclipse.ui.services.ISourceProviderService;
import org.jastadd.plugin.Activator;
import org.jmodelica.ide.documentation.commands.NavigationProvider;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class DocumentationEditor extends EditorPart {

	private Label contents;
	private Browser browser;
	private DocumentationEditorInput input;
	private InstClassDecl icd;
	private SourceRoot sourceRoot;
	private FullClassDecl fullClassDecl;
	private BrowserContent browserContent;
	
	public DocumentationEditor() {
	}
	
	@Override
	public void createPartControl(Composite parent) {
		ISourceProviderService sourceProviderService = (ISourceProviderService)this.getSite().getWorkbenchWindow().getService(ISourceProviderService.class);
		NavigationProvider navProv = (NavigationProvider) sourceProviderService.getSourceProvider(NavigationProvider.NAVIGATION_FORWARD);
		//IHandlerService handlerService = (IHandlerService) getSite().getService(IHandlerService.class);
		sourceRoot = (SourceRoot) Activator.getASTRegistry().lookupAST(null, this.input.getProject());
		icd = sourceRoot.getProgram().getInstProgramRoot().simpleLookupInstClassDecl(this.input.getClassName());
		//openComponentStack = new Stack<InstComponentDecl>();
		//program = sourceRoot.getProgram();
		//String s = input.getClassName();
		
		fullClassDecl = input.getFullClassDecl();
		if (fullClassDecl == null){
			//fullClassDecl = (FullClassDecl) program.simpleLookupClassDotted(input.getClassName());
		}
		browser = new Browser(parent, SWT.NONE);
		browserContent = new BrowserContent(fullClassDecl, browser, icd, sourceRoot.getProgram(), navProv);
     }
	
	public boolean back(){
		return browserContent.back();
	}
	public boolean forward(){
		return browserContent.forward();
	}
	
	@Override
	protected void setInput(IEditorInput input){
		super.setInput(input);
		Assert.isLegal(input instanceof DocumentationEditorInput, "The viewer only support opening Modelica classes.");
		this.input = (DocumentationEditorInput)input;
		setPartName(input.getName());
	}
	
	@Override
	public void doSave(final IProgressMonitor monitor) {
		if (icd == null)
			return;

		SafeRunner.run(new SafeRunnable() {
			public void run() throws Exception {
				StoredDefinition definition = icd.getDefinition();
				definition.getFile().setContents(new ByteArrayInputStream(definition.prettyPrintFormatted().getBytes()), false, true, monitor);
			}
		});
	}
	
	@Override
	public void doSaveAs() {
	}

	@Override
	public void init(IEditorSite site, IEditorInput input) throws PartInitException {
		setSite(site);
        setInput(input);
	}

	@Override
	public boolean isDirty() {
		return false;
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

}
