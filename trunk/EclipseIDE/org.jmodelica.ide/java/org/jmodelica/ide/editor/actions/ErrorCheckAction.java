package org.jmodelica.ide.editor.actions;


import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.PlatformUI;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.error.InstanceError;
import org.jmodelica.ide.error.InstanceErrorHandler;
import org.jmodelica.modelica.compiler.BaseClassDecl;
import org.jmodelica.modelica.compiler.CompilationHooks;
import org.jmodelica.modelica.compiler.FClass;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstProgramRoot;
import org.jmodelica.modelica.compiler.ModelicaCompiler;
import org.jmodelica.modelica.compiler.SourceRoot;

public class ErrorCheckAction extends CurrentClassAction {
	
	public ErrorCheckAction() {
		super();
		super.setActionDefinitionId(IDEConstants.COMMAND_ERROR_CHECK_ID);
		super.setId(IDEConstants.ACTION_ERROR_CHECK_ID);
	}

	@Override
	public void run() {
		SourceRoot root = (SourceRoot) currentClass.root();
		InstProgramRoot ipr = root.getProgram().getInstProgramRoot();
		InstanceErrorHandler errorHandler = new InstanceErrorHandler();
		root.setErrorHandler(errorHandler);
		errorHandler.resetCounter();
		String name = currentClass.qualifiedName();
		InstClassDecl icd = ipr.simpleLookupInstClassDecl(name);
		icd.resetCollectErrors();
		icd.collectErrors();
		if (!errorHandler.hasErrors()) {
			ModelicaCompiler mc = new ModelicaCompiler(icd.root().options);
			FClass fc = mc.createFlatTree(icd, icd.fileName());
			icd.flattenInstClassDecl(fc);
			fc.setLocation(icd.getSelectionNode());
			fc.setDefinition(icd.getDefinition());
			fc.transformCanonical();
			fc.collectErrors();
		}
		
		String msg = errorHandler.resultMessage();
		String title = "Checking " + currentClass.getName().getID()	+ " for errors:";
		Shell shell = PlatformUI.getWorkbench().getDisplay().getActiveShell();
		MessageDialog.openInformation(shell, title, msg);
	}

	@Override
	protected String getNewText(BaseClassDecl currentClass) {
        if (currentClass != null) 
            return "Check '" + currentClass.getName().getID() + "' for errors";
        else
        	return IDEConstants.ACTION_ERROR_CHECK_TEXT;
	}

	protected static class ErrorCheckJob extends Job {

		public ErrorCheckJob(String name) {
			super(name);
			// TODO Auto-generated constructor stub
		}

		protected IStatus run(IProgressMonitor monitor) {
			// TODO Auto-generated method stub
			return null;
		}
	}
	
}
