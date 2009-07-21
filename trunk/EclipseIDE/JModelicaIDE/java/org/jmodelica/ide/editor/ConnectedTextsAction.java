package org.jmodelica.ide.editor;

import org.eclipse.jface.action.Action;

public class ConnectedTextsAction extends Action {
protected void setTexts(String text) {
    setText(text);
    setToolTipText(text);
    setDescription(text);
}
}