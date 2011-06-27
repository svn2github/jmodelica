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

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.texteditor.AbstractTextEditor;
import org.eclipse.ui.views.contentoutline.IContentOutlinePage;
import org.jmodelica.ide.editor.Editor;
import org.jmodelica.ide.editor.ICurrentClassListener;
import org.jmodelica.ide.helpers.EclipseUtil;

public class ClassOutlineView extends OutlineView {
	
	private Map<IProject, ClassOutlinePage> mapProjToPage = new HashMap<IProject, ClassOutlinePage>();
	
	protected IContentOutlinePage setupOutlinePage(IWorkbenchPart part) {
		if (part instanceof AbstractTextEditor) {
			AbstractTextEditor editor = (AbstractTextEditor) part;
			IProject project = getProjectOfEditor(editor);
			if (project != null) {
				ClassOutlinePage page = mapProjToPage.get(project);
				if (page == null && EclipseUtil.isModelicaProject(project)) {
					page = new ClassOutlinePage(project, editor);
					mapProjToPage.put(project, page);
					initPage(page);
					page.createControl(getPageBook());
				}
				if (editor instanceof ICurrentClassListener) 
					page.addCurrentClassListener((ICurrentClassListener) editor);
				return page;
			}
		}
		return null;
	}

	protected void doDestroyPage(IWorkbenchPart part, PageRec rec) {
		if (part instanceof AbstractTextEditor) 
			mapProjToPage.remove(getProjectOfEditor((AbstractTextEditor) part));
		super.doDestroyPage(part, rec);
	}
	
	public void partClosed(IWorkbenchPart part) {
		if (part instanceof ICurrentClassListener) {
			PageRec rec = getPageRec(part);
			if (rec != null && rec.page instanceof ClassOutlinePage) {
				ClassOutlinePage page = (ClassOutlinePage) rec.page;
				page.removeCurrentClassListener((ICurrentClassListener) part);
			}
		}
		super.partClosed(part);
	}

	/**
	 * Get the project connected to the given text editor's opened file, if any.
	 */
	protected IProject getProjectOfEditor(AbstractTextEditor editor) {
		IEditorInput input = editor.getEditorInput();
		if (input instanceof IFileEditorInput) {
			IFile file = ((IFileEditorInput) input).getFile();
			if (file != null)
				return file.getProject();
		}
		return null;
	}

	protected boolean isImportant(IWorkbenchPart part) {
		if (part instanceof AbstractTextEditor) {
			IProject project = getProjectOfEditor((AbstractTextEditor) part);
			return EclipseUtil.isModelicaProject(project);
		} else {
			return false;
		}
	}

	public void partActivated(IWorkbenchPart part) {
		if (isImportant(part))
			super.partActivated(part);
	}

	public void partBroughtToTop(IWorkbenchPart part) {
		partActivated(part);
	}

	protected void partHidden(IWorkbenchPart part) {
	}

	protected IContentOutlinePage getOutlinePage(Editor part) {
		return null;
	}

}
