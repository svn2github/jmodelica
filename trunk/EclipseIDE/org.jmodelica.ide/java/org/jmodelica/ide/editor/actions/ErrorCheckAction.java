package org.jmodelica.ide.editor.actions;


import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.IJobChangeEvent;
import org.eclipse.core.runtime.jobs.IJobChangeListener;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.jface.dialogs.MessageDialog;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.error.InstanceErrorHandler;
import org.jmodelica.ide.helpers.EclipseUtil;
import org.jmodelica.ide.helpers.ShowMessageJob;
import org.jmodelica.modelica.compiler.BaseClassDecl;
import org.jmodelica.modelica.compiler.FClass;
import org.jmodelica.modelica.compiler.IErrorHandler;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstProgramRoot;
import org.jmodelica.modelica.compiler.ModelicaCompiler;
import org.jmodelica.modelica.compiler.SourceRoot;

public class ErrorCheckAction extends CurrentClassAction implements IJobChangeListener {
	
	public ErrorCheckAction() {
		super();
		super.setActionDefinitionId(IDEConstants.COMMAND_ERROR_CHECK_ID);
		super.setId(IDEConstants.ACTION_ERROR_CHECK_ID);
	}

	@Override
	public void run() {
		ErrorCheckJob job = new ErrorCheckJob(currentClass);
		job.addJobChangeListener(this);
		job.schedule();
	}

	@Override
	protected String getNewText(BaseClassDecl currentClass) {
        if (currentClass != null) 
            return "Check '" + currentClass.getName().getID() + "' for errors";
        else
        	return IDEConstants.ACTION_ERROR_CHECK_TEXT;
	}

	public void done(IJobChangeEvent event) {
		String title = event.getJob().getName();
		String message = event.getResult().getMessage();
		int kind = (event.getResult().getSeverity() == IStatus.INFO) ? MessageDialog.ERROR : MessageDialog.INFORMATION;
		new ShowMessageJob(title, message, kind).schedule();
	}

	public void aboutToRun(IJobChangeEvent event) {
	}

	public void awake(IJobChangeEvent event) {
	}

	public void running(IJobChangeEvent event) {
	}

	public void scheduled(IJobChangeEvent event) {
	}

	public void sleeping(IJobChangeEvent event) {
	}

	protected static class ErrorCheckJob extends Job {

		private BaseClassDecl currentClass;

		public ErrorCheckJob(BaseClassDecl currentClass) {
			super("Checking " + currentClass.getName().getID()	+ " for errors:");
			setUser(true);
			this.currentClass = currentClass;
		}

		protected IStatus run(IProgressMonitor monitor) {
			SourceRoot root = (SourceRoot) currentClass.root();
			InstProgramRoot ipr = root.getProgram().getInstProgramRoot();
			InstanceErrorHandler errorHandler = getErrorHandler(root);
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
			int status = errorHandler.hasErrors() ? IStatus.INFO : IStatus.OK;
			return new Status(status, IDEConstants.PLUGIN_ID, errorHandler.resultMessage());
		}

		private InstanceErrorHandler getErrorHandler(SourceRoot root) {
			IErrorHandler handler = root.getErrorHandler();
			InstanceErrorHandler errorHandler;
			if (handler instanceof InstanceErrorHandler) {
				errorHandler = (InstanceErrorHandler) handler;
				errorHandler.resetCounter();
			} else {
				errorHandler = new InstanceErrorHandler();
				root.setErrorHandler(errorHandler);
			}
			return errorHandler;
		}
		
	}
	
}
