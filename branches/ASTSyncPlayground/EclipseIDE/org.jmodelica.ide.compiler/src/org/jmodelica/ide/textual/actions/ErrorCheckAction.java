package org.jmodelica.ide.textual.actions;

import java.util.HashSet;
import java.util.Set;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.IJobChangeEvent;
import org.eclipse.core.runtime.jobs.IJobChangeListener;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.PlatformUI;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.compiler.LocalRootNode;
import org.jmodelica.ide.compiler.ModelicaASTRegistry;
import org.jmodelica.ide.error.InstanceErrorHandler;
import org.jmodelica.ide.helpers.ShowMessageJob;
import org.jmodelica.ide.helpers.hooks.IErrorCheckHook;
import org.jmodelica.ide.outline.cache.CachedClassDecl;
import org.jmodelica.modelica.compiler.BaseClassDecl;
import org.jmodelica.modelica.compiler.FClass;
import org.jmodelica.modelica.compiler.IErrorHandler;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstProgramRoot;
import org.jmodelica.modelica.compiler.ModelicaCompiler;
import org.jmodelica.modelica.compiler.SourceRoot;

public class ErrorCheckAction extends CurrentClassAction implements
		IJobChangeListener {

	private static final String SYNTAX_ERROR_MESSAGE = "Project contains files with syntax errors.\nError check might give erroneous results.";
	private static final String SYNTAX_ERROR_TITLE = "Syntax errors in project";
	private static Set<IErrorCheckHook> hooks = new HashSet<IErrorCheckHook>();

	public static void addErrorCheckHook(IErrorCheckHook hook) {
		hooks.add(hook);
	}

	public static void removeErrorCheckHook(IErrorCheckHook hook) {
		hooks.remove(hook);
	}

	public ErrorCheckAction() {
		super();
		super.setActionDefinitionId(IDEConstants.COMMAND_ERROR_CHECK_ID);
		super.setId(IDEConstants.ACTION_ERROR_CHECK_ID);
	}

	@Override
	public void run() {
		for (IErrorCheckHook hook : hooks)
			hook.beforeCheck();
		checkForSyntaxErrors();
		ErrorCheckJob job = new ErrorCheckJob(currentClass);
		job.addJobChangeListener(this);
		job.schedule();
	}

	public void checkForSyntaxErrors() {
		LocalRootNode ln = (LocalRootNode)ModelicaASTRegistry.getInstance().lookupFile(currentClass.containingFileName());
		IFile file = ln.getFile();
		if (file != null) {
			try {
				String type = IDEConstants.ERROR_MARKER_SYNTACTIC_ID;
				int depth = IResource.DEPTH_INFINITE;
				int sev = file.getProject().findMaxProblemSeverity(type, false,
						depth);
				if (sev >= IMarker.SEVERITY_ERROR) {
					Shell shell = PlatformUI.getWorkbench().getDisplay()
							.getActiveShell();
					MessageDialog.openWarning(shell, SYNTAX_ERROR_TITLE,
							SYNTAX_ERROR_MESSAGE);
				}
			} catch (CoreException e) {
			}
		}
	}

	@Override
	protected String getNewText(CachedClassDecl currentClass) {
		if (currentClass != null)
			return "Check '" + currentClass.qualifiedName() + "' for errors";
		else
			return IDEConstants.ACTION_ERROR_CHECK_TEXT;
	}

	public void done(IJobChangeEvent event) {
		String title = event.getJob().getName();
		String message = event.getResult().getMessage();
		int severity = event.getResult().getSeverity();
		int kind = (severity == IStatus.OK) ? MessageDialog.INFORMATION
				: MessageDialog.ERROR;
		boolean expanded = message.contains("\n\n");
		new ShowMessageJob(title, message, kind, expanded).schedule();
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

		private CachedClassDecl currentClass;

		public ErrorCheckJob(CachedClassDecl currentClass) {
			// super("Checking " + currentClass.getName().getID() +
			// " for errors:");
			super("Checking " + currentClass.qualifiedName() + " for errors:");
			setUser(true);
			this.currentClass = currentClass;
		}

		protected IStatus run(IProgressMonitor monitor) {
			LocalRootNode ln = (LocalRootNode) ModelicaASTRegistry
					.getInstance()
					.lookupFile(currentClass.containingFileName());
			if (ln != null) {
				SourceRoot root = ln.getSourceRoot();
				synchronized (root.state()) {
					InstProgramRoot ipr = root.getProgram()
							.getInstProgramRoot();
					InstanceErrorHandler errorHandler = getErrorHandler(root);
					String name = currentClass.qualifiedName();
					InstClassDecl icd = ipr.simpleLookupInstClassDecl(name);
					icd.resetCollectErrors();
					icd.collectErrors();
					if (!errorHandler.hasErrors()) {
						ModelicaCompiler mc = new ModelicaCompiler(
								icd.root().options);
						FClass fc = FClass.create(icd, icd.fileName());
						icd.flattenInstClassDecl(fc);
						fc.setLocation(icd.getSelectionNode());
						fc.setDefinition(icd.getDefinition());
						fc.transformCanonical();
						fc.collectErrors();
					}

					// We use the severity to tell what kind of message is
					// passed
					int status = IStatus.OK; // No errors
					if (errorHandler.hasErrors())
						status = IStatus.INFO; // Only errors that we created
												// markers for
					if (errorHandler.hasLostErrors())
						status = IStatus.WARNING; // Some errors that no markers
													// were created for

					return new Status(status, IDEConstants.PLUGIN_ID,
							errorHandler.resultMessage());
				}
			}
			return null;
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
