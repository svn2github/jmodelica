package org.jmodelica.ide.textual.actions;

import org.eclipse.jface.action.Action;

public abstract class ConnectedTextsAction extends Action {

	protected void setTexts(String text) {
		setText(text);
		setToolTipText(text);
		setDescription(text);
	}

}