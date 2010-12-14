package org.jmodelica.ide.editor.actions;

import java.io.File;

import org.eclipse.jface.action.Action;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.DirectoryDialog;
import org.eclipse.swt.widgets.MessageBox;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.PlatformUI;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.editor.Editor;
import org.jmodelica.modelica.compiler.BaseClassDecl;
import org.jmodelica.modelica.compiler.ModelicaCompiler;
import org.jmodelica.util.OptionRegistry;

public class CompileFMUAction extends CurrentClassAction {
	
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
			OptionRegistry opt = currentClass.root().options;
			String className = currentClass.qualifiedName();
			String[] paths = editor.editorFile().getPaths();
			ModelicaCompiler mc = new ModelicaCompiler(opt);
			mc.compileFMU(className, paths, "model_noad", dir);
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

}
