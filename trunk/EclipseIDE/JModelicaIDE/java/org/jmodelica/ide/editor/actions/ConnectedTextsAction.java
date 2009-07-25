package org.jmodelica.ide.editor.actions;

import org.eclipse.jface.action.Action;

public class ConnectedTextsAction extends Action {
protected void setTexts(String text) {
    setText(text);
    setToolTipText(text);
    setDescription(text);
}
}