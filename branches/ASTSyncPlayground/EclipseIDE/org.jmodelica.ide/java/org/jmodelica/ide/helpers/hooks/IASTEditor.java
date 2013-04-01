package org.jmodelica.ide.helpers.hooks;

import org.eclipse.ui.views.contentoutline.IContentOutlinePage;
import org.jmodelica.modelica.compiler.ClassDecl;

public interface IASTEditor {

	ClassDecl getClassContainingCursor();
	IContentOutlinePage getInstanceOutlinePage();
	IContentOutlinePage getSourceOutlinePage();
	boolean selectNode(boolean notNull, String containingFileName,
			int getSelectionNodeOffset,
			int getSelectionNodeLength);
}
