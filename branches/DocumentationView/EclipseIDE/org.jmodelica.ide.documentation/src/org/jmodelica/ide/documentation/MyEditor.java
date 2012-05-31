package org.jmodelica.ide.documentation;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Stack;
import org.eclipse.core.runtime.Assert;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.swt.SWT;
import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.browser.LocationEvent;
import org.eclipse.swt.browser.LocationListener;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorSite;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.part.EditorPart;
import org.jastadd.plugin.Activator;
import org.jmodelica.icons.Icon;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.AnnotationNode;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.ComponentDecl;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.ImportClause;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstComponentDecl;
import org.jmodelica.modelica.compiler.List;
import org.jmodelica.modelica.compiler.Program;
import org.jmodelica.modelica.compiler.SourceRoot;

public class MyEditor extends EditorPart {

	private Label contents;
	private Browser browser;
	private MyEditorInput input;
	private InstClassDecl icd;
	private Stack<InstComponentDecl> openComponentStack;
	private SourceRoot sourceRoot;
	private FullClassDecl fullClassDecl;
	private BrowserContent browserContent;
	private Program program;
	private String currentLocation;
	
	public MyEditor() {
	}
	
	@Override
	public void createPartControl(Composite parent) {
		sourceRoot = (SourceRoot) Activator.getASTRegistry().lookupAST(null, this.input.getProject());
		icd = sourceRoot.getProgram().getInstProgramRoot().simpleLookupInstClassDecl(this.input.getClassName());
		//openComponentStack = new Stack<InstComponentDecl>();
		//program = sourceRoot.getProgram();
		//String s = input.getClassName();
		fullClassDecl = input.getFullClassDecl();
//		if (fullClassDecl == null){
//			//fullClassDecl = (FullClassDecl) program.simpleLookupClassDotted(input.getClassName());
//		}
		browser = new Browser(parent, SWT.NONE);
		browserContent = new BrowserContent(fullClassDecl, browser, icd);
     }
	
	@Override
	protected void setInput(IEditorInput input){
		super.setInput(input);
		Assert.isLegal(input instanceof MyEditorInput, "The viewer only support opening Modelica classes.");
		this.input = (MyEditorInput)input;
		setPartName(input.getName());
	}
	
	@Override
	public void doSave(IProgressMonitor monitor) {
		// TODO Auto-generated method stub
	}
	
	@Override
	public void doSaveAs() {
		// TODO Auto-generated method stub
	}

	@Override
	public void init(IEditorSite site, IEditorInput input) throws PartInitException {
		setSite(site);
        setInput(input);
	}

	@Override
	public boolean isDirty() {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean isSaveAsAllowed() {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public void setFocus() {
		if (contents != null)
            contents.setFocus();
	}

}
