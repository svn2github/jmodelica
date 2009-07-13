
package org.jmodelica.ide.editor;

import org.eclipse.jface.text.ITextOperationTarget;
import org.eclipse.jface.text.source.ISourceViewer;
import org.jmodelica.folding.CharacterProjectionViewer;

public class ToggleAnnotationsAction extends Editor.ConnectedTextsAction {

protected Editor editor;
protected boolean visible;    

public ToggleAnnotationsAction(Editor editor) {
    editor.super();
    this.editor = editor;
    update(false);
    this.setActionDefinitionId("JModelicaIDE.ModelicaToggleAnnotationCommand");
}

public boolean isVisible() {
    return visible;
}

@Override
public void run() {
    update(!visible);
    int action = visible ? CharacterProjectionViewer.EXPAND_ANNOTATIONS : CharacterProjectionViewer.COLLAPSE_ANNOTATIONS;
    ISourceViewer sourceViewer = editor.publicGetSourceViewer();
    if (sourceViewer instanceof ITextOperationTarget) {
        ((ITextOperationTarget) sourceViewer).doOperation(action);
    }
}

private void update(boolean visible) {
    this.visible = visible;
    setChecked(visible);
}
}
