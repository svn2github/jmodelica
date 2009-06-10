package org.jmodelica.ide.outline;

import org.eclipse.ui.views.contentoutline.IContentOutlinePage;
import org.jmodelica.ide.editor.Editor;

public class InstanceOutlineView extends OutlineView {

	@Override
	protected IContentOutlinePage getOutlinePage(Editor part) {
		return part.getInstanceOutlinePage();
	}

}
