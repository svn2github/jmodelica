package org.jmodelica.ide.editor.actions;

import java.util.Collection;

import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.widgets.Shell;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.error.InstanceError;
import org.jmodelica.ide.error.InstanceErrorHandler;
import org.jmodelica.modelica.compiler.BaseClassDecl;
import org.jmodelica.modelica.compiler.InstProgramRoot;
import org.jmodelica.modelica.compiler.SourceRoot;

public class ErrorCheckAction extends CurrentClassAction {
	private static final int MAX_ERRORS_SHOWN = 10;

	public ErrorCheckAction() {
		super();
		super.setActionDefinitionId(IDEConstants.COMMAND_ERROR_CHECK_ID);
		super.setId(IDEConstants.ACTION_ERROR_CHECK_ID);
	}

	@Override
	public void run() {
		// performSave(true, null);
		SourceRoot root = (SourceRoot) currentClass.root();
		InstProgramRoot ipr = root.getProgram().getInstProgramRoot();
		InstanceErrorHandler errorHandler = (InstanceErrorHandler) root.getErrorHandler();
		errorHandler.resetCounter();
		String name = currentClass.qualifiedName();
		ipr.simpleLookupInstClassDecl(name).collectErrors();
		String msg;
		if (errorHandler.hasLostErrors()) {
			Collection<InstanceError> err = errorHandler.getLostErrors();
			StringBuilder buf = new StringBuilder("Errors found in files outside workspace:\n");
			if (err.size() > MAX_ERRORS_SHOWN)
				buf.append(String.format("(First %d of %d errors shown.)",
						MAX_ERRORS_SHOWN, err.size()));
			int i = 0;
			for (InstanceError e : err)
				if (i++ < MAX_ERRORS_SHOWN)
					buf.append(e);
			msg = buf.toString();
		} else {
			int num = errorHandler.getNumErrors();
			if (num == 0)
				msg = "No errors found.";
			else
				msg = num + " errors found.";
		}
		String title = "Checking " + currentClass.getName().getID()	+ " for errors:";
		MessageDialog.openInformation(new Shell(), title, msg);
	}

	@Override
	protected String getNewText(BaseClassDecl currentClass) {
        if (currentClass != null) 
            return "Check '" + currentClass.getName().getID() + "' for errors";
        else
        	return IDEConstants.ACTION_ERROR_CHECK_TEXT;
	}
}
