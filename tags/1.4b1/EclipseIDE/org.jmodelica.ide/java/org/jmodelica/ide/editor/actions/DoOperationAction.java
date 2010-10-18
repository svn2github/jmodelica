package org.jmodelica.ide.editor.actions;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.text.ITextOperationTarget;
import org.eclipse.jface.text.source.ISourceViewer;
import org.jmodelica.ide.editor.Editor;

public class DoOperationAction extends Action {

protected int action;
protected Editor editor;

public DoOperationAction(String text, int action, Editor editor) {
    
    super(text);
    this.action = action;
    this.editor = editor;
    
}

@Override
public void run() {
    
    ISourceViewer sourceViewer = editor.sourceViewer();
    
    if (sourceViewer instanceof ITextOperationTarget) 
        ((ITextOperationTarget) sourceViewer).doOperation(action);
    
}
}
