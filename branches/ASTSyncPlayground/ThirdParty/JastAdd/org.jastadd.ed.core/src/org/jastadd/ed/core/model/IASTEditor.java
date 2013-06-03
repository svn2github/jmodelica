package org.jastadd.ed.core.model;

import org.eclipse.ui.views.contentoutline.IContentOutlinePage;
import org.jastadd.ed.core.model.node.IASTNode;

public interface IASTEditor {

	IASTNode getClassContainingCursor();
	IContentOutlinePage getInstanceOutlinePage();
	IContentOutlinePage getSourceOutlinePage();
	boolean selectNode(boolean notNull, String containingFileName,
			int getSelectionNodeOffset,
			int getSelectionNodeLength);
}
