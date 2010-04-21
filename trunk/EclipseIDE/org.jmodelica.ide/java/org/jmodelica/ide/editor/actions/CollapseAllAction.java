package org.jmodelica.ide.editor.actions;

import org.jmodelica.folding.CharacterProjectionViewer;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.editor.Editor;

public class CollapseAllAction extends DoOperationAction {


public CollapseAllAction(Editor editor) {

    super("&Collapse All", CharacterProjectionViewer.COLLAPSE_ALL, editor);
    super.setId(IDEConstants.ACTION_COLLAPSE_ALL_ID);

}

}
