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


public class ErrorCheckAction extends ConnectedTextsAction {
private static final int MAX_ERRORS_SHOWN = 10;
private BaseClassDecl currentClass;

public ErrorCheckAction() {
    super();
    setTexts(IDEConstants.ACTION_ERROR_CHECK_TEXT);
    setEnabled(false);
    super.setActionDefinitionId("JModelicaIDE.ErrorCheckCommand");
}

public void setCurClass(BaseClassDecl currentClass) {
    if (currentClass != this.currentClass) {
        this.currentClass = currentClass;
        if (currentClass != null) {
            setTexts("Check " + currentClass.getName().getID() + " for errors");
            setEnabled(true);
        } else {
            setTexts(IDEConstants.ACTION_ERROR_CHECK_TEXT);
            setEnabled(false);
        }
    }
}

@Override
public void run() {
    // performSave(true, null);
    SourceRoot root = (SourceRoot) currentClass.root();
    InstProgramRoot ipr = root.getProgram().getInstProgramRoot();
    InstanceErrorHandler errorHandler = (InstanceErrorHandler) root
            .getErrorHandler();
    errorHandler.resetCounter();
    String name = currentClass.qualifiedName();
    ipr.retrieveInstFullClassDecl(name).collectErrors();
    String msg;
    if (errorHandler.hasLostErrors()) {
        Collection<InstanceError> err = errorHandler.getLostErrors();
        StringBuilder buf = new StringBuilder(
                "Errors found in files outside workspace:\n");
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
    String title = "Checking " + currentClass.getName().getID()
            + " for errors:";
    MessageDialog.openInformation(new Shell(), title, msg);
}
}
