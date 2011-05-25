package org.jmodelica.ide.actions;

import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.editor.ICurrentClassListener;
import org.jmodelica.modelica.compiler.BaseClassDecl;

public abstract class CurrentClassAction extends ConnectedTextsAction implements ICurrentClassListener {

	protected BaseClassDecl currentClass;

	public CurrentClassAction() {
		super();
        setTexts(getNewText(null));
        setEnabled(false);
	}

	public void setCurrentClass(BaseClassDecl currentClass) {
	    if (currentClass != this.currentClass) {
	        this.currentClass = currentClass;
	        setTexts(getNewText(currentClass));
	        setEnabled(currentClass != null);
	    }
	}

	protected abstract String getNewText(BaseClassDecl currentClass);

}