package org.jmodelica.ide.editor.actions;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.IJobChangeEvent;
import org.eclipse.core.runtime.jobs.IJobChangeListener;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.DirectoryDialog;
import org.eclipse.swt.widgets.MessageBox;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.PlatformUI;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.editor.Editor;
import org.jmodelica.modelica.compiler.BaseClassDecl;
import org.jmodelica.modelica.compiler.CompilationAbortedException;
import org.jmodelica.modelica.compiler.CompilationHooks;
import org.jmodelica.modelica.compiler.CompilerException;
import org.jmodelica.modelica.compiler.FClass;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.ModelicaClassNotFoundException;
import org.jmodelica.modelica.compiler.ModelicaCompiler;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.util.OptionRegistry;

public class CompileFMUAction extends CurrentClassAction implements IJobChangeListener {
	
	// TODO: Open a console and run compilation there
	// TODO: Add preference for default output dir
	// TODO: Take "current class" from outline instead of editor
	
	protected Editor editor;
	protected DirectoryDialog outputDirDlg;
	
	public CompileFMUAction(Editor editor) {
		super();
		super.setActionDefinitionId(IDEConstants.COMMAND_COMPILE_FMU_ID);
		super.setId(IDEConstants.ACTION_COMPILE_FMU_ID);
		this.editor = editor;
	}

	@Override
	protected String getNewText(BaseClassDecl currentClass) {
        if (currentClass != null) 
            return "Compile '" + currentClass.getName().getID() + "' to FMU";
        else
        	return IDEConstants.ACTION_COMPILE_FMU_TEXT;
	}
	
	@Override
	public boolean isEnabled() {
		if (!super.isEnabled())
			return false;
		String jmHome = ModelicaCompiler.getJModelicaHome();
		if (jmHome == null)
			return false;
		return new File(jmHome).isDirectory();
	}

	@Override
	public void run() {
		String dir = askForDir();
		if (dir != null) {
			OptionRegistry opt = new OptionRegistry(currentClass.root().options);
			String className = currentClass.qualifiedName();
			String[] paths = editor.editorFile().getPaths();
			Job job = new CompileJob(className, paths, dir, opt);
			job.setUser(true);
			job.addJobChangeListener(this);
			job.schedule();
		}
	}

	protected String askForDir() {
		if (outputDirDlg == null || outputDirDlg.getParent().isDisposed()) {
			Shell shell = PlatformUI.getWorkbench().getDisplay().getActiveShell();
			outputDirDlg = new DirectoryDialog(shell);
			outputDirDlg.setMessage("Select output directory for FMU");
			outputDirDlg.setText("Select output directory");
		}		
		return outputDirDlg.open();
	}

	public void done(IJobChangeEvent event) {
		if (event.getResult().getSeverity() == IStatus.ERROR) {
			Shell shell = PlatformUI.getWorkbench().getDisplay().getActiveShell();
			String title = event.getJob().getName();
			MessageDialog.openError(shell, title, event.getResult().getMessage());
		}
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
	
	protected static class CompileJob extends Job implements CompilationHooks {

		private static final int WORK_PARSE       = 1;
		private static final int WORK_INSTANTIATE = 5;
		private static final int WORK_FLATTEN     = 1;
		private static final int WORK_TRANSFORM   = 1;
		private static final int WORK_FLAT_CHECK  = 1;
		private static final int WORK_GENERATE    = 1;
		private static final int WORK_COMPILE_C   = 2;
		private static final int WORK_PACK        = 1;
		
		private static final int WORK_TOTAL = 
			WORK_PARSE + WORK_INSTANTIATE + WORK_FLATTEN + WORK_TRANSFORM + 
			WORK_FLAT_CHECK + WORK_GENERATE + WORK_COMPILE_C + WORK_PACK;
		
		private IProgressMonitor mon;
		private String className;
		private String[] paths;
		private String dir;
		private OptionRegistry opt;

		public CompileJob(String className, String[] paths, String dir, OptionRegistry opt) {
			super("Compiling " + className + " to FMU");
			this.className = className;
			this.paths = paths;
			this.dir = dir;
			this.opt = opt;
		}

		@Override
		protected IStatus run(IProgressMonitor monitor) {
			mon = monitor;
			mon.beginTask("Compiling...", WORK_TOTAL);
			IStatus status = Status.OK_STATUS;
			try {
				ModelicaCompiler mc = new ModelicaCompiler(opt);
				mc.addCompilationHooks(this);
				mc.compileFMU(className, paths, "model_noad", dir);
			} catch (CompilationAbortedException e) {
				status = Status.CANCEL_STATUS;
			} catch (Exception e) {
				String msg = "Error compiling " + className + " to FMU";
				if (e.getMessage() != null)
					msg += ":\n" + e.getMessage();
				status = new Status(IStatus.ERROR, IDEConstants.PLUGIN_ID, msg, e); 
			}
			mon.done();
			return status;
		}

		@Override
		public boolean shouldAbort() {
			return mon.isCanceled();
		}

		@Override
		public void filesParsed(SourceRoot sr) {
			mon.worked(WORK_PARSE);
		}

		@Override
		public void modelInstantiatied(InstClassDecl icd) {
			mon.worked(WORK_INSTANTIATE);
		}

		@Override
		public void modelFlattened(FClass fc) {
			mon.worked(WORK_FLATTEN);
		}

		@Override
		public void modelTransformed(FClass fc) {
			mon.worked(WORK_TRANSFORM);
		}

		@Override
		public void flatModelChecked(FClass fc) {
			mon.worked(WORK_FLAT_CHECK);
		}

		@Override
		public void codeGenerated() {
			mon.worked(WORK_GENERATE);
		}

		@Override
		public void codeCompiled() {
			mon.worked(WORK_COMPILE_C);
		}

		@Override
		public void fmuPacked(String path) {
			mon.worked(WORK_PACK);
		}
		
	}

}
