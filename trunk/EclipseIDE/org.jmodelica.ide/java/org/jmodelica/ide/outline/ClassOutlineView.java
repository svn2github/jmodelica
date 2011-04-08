/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package org.jmodelica.ide.outline;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.resources.IProject;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.part.IPageBookViewPage;
import org.eclipse.ui.texteditor.AbstractTextEditor;
import org.eclipse.ui.views.contentoutline.IContentOutlinePage;
import org.jmodelica.ide.editor.Editor;

public class ClassOutlineView extends OutlineView {
	
	private Map<IProject, ClassOutlinePage> map = new HashMap<IProject, ClassOutlinePage>();
	
	protected IContentOutlinePage setupOutlinePage(IWorkbenchPart part) {
		// TODO: try to remove dependency on AbstractTextEditor, replace with IEditorPart
		if (part instanceof AbstractTextEditor) {
			AbstractTextEditor editor = (AbstractTextEditor) part;
			IEditorInput input = editor.getEditorInput();
			if (input instanceof IFileEditorInput) {
				IProject project = ((IFileEditorInput) input).getFile().getProject();
				ClassOutlinePage page = map.get(project);
				if (page == null) {
					page = new ClassOutlinePage(project, editor);
					map.put(project, page);
					initPage(page);
					page.createControl(getPageBook());
				}
				return page;
			}
		}
		return null;
	}

	protected boolean isImportant(IWorkbenchPart part) {
		return part instanceof AbstractTextEditor;
	}

	protected IContentOutlinePage getOutlinePage(Editor part) {
		return null;
	}

}
