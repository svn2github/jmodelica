package org.jmodelica.ide.actions;

import org.eclipse.jface.text.source.projection.ProjectionViewer;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.editor.Editor;

public class CollapseAllAction extends DoOperationAction {


public CollapseAllAction(Editor editor) {

    super("&Collapse All", ProjectionViewer.COLLAPSE_ALL, editor);
    super.setId(IDEConstants.ACTION_COLLAPSE_ALL_ID);

}

}
