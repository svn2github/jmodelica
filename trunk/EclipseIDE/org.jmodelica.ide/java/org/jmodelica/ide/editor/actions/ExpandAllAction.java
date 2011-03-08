package org.jmodelica.ide.editor.actions;

import org.eclipse.jface.text.source.projection.ProjectionViewer;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.editor.Editor;

public class ExpandAllAction extends DoOperationAction {

public ExpandAllAction(Editor editor) {

    super("&Expand All", ProjectionViewer.EXPAND_ALL, editor);
    super.setId(IDEConstants.ACTION_EXPAND_ALL_ID);
    
}

}
