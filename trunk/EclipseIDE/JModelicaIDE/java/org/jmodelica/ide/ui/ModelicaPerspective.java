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
package org.jmodelica.ide.ui;

import org.eclipse.ui.IFolderLayout;
import org.eclipse.ui.IPageLayout;
import org.eclipse.ui.IPerspectiveFactory;
import org.eclipse.ui.progress.IProgressConstants;
import org.jmodelica.ide.IDEConstants;

public class ModelicaPerspective implements IPerspectiveFactory {

	@SuppressWarnings("deprecation")
    public void createInitialLayout(IPageLayout layout) {
		String edit = layout.getEditorArea();
		layout.setEditorAreaVisible(true);
		
		// Shortcuts
		layout.addPerspectiveShortcut(IDEConstants.PERSPECTIVE_ID);
		
		layout.addNewWizardShortcut(IDEConstants.WIZARD_FILE_ID);
		layout.addNewWizardShortcut(IDEConstants.WIZARD_PROJECT_ID);
		layout.addNewWizardShortcut("org.eclipse.ui.wizards.new.folder");
		layout.addNewWizardShortcut("org.eclipse.ui.wizards.new.file");
		layout.addNewWizardShortcut("org.eclipse.ui.editors.wizards.UntitledTextFileWizard");
		
		layout.addShowViewShortcut("org.eclipse.ui.navigator.ProjectExplorer");
		layout.addShowViewShortcut(IDEConstants.INSTANCE_OUTLINE_VIEW_ID);
		layout.addShowViewShortcut(IPageLayout.ID_OUTLINE);
		layout.addShowViewShortcut(IPageLayout.ID_PROBLEM_VIEW);
		layout.addShowViewShortcut(IPageLayout.ID_RES_NAV);
		layout.addShowViewShortcut(IPageLayout.ID_TASK_LIST);
		layout.addShowViewShortcut(IProgressConstants.PROGRESS_VIEW_ID);
//		layout.addShowViewShortcut(NewSearchUI.SEARCH_VIEW_ID);     // Later?
//		layout.addShowViewShortcut(IConsoleConstants.ID_CONSOLE_VIEW);     // Later?
		
		// Explorer view
		IFolderLayout explorefolder = layout.createFolder("left", IPageLayout.LEFT, (float)0.25, edit);
		explorefolder.addView("org.eclipse.ui.navigator.ProjectExplorer");
		
		// Problems view, progress view, etc
		IFolderLayout outputfolder = layout.createFolder("bottom", IPageLayout.BOTTOM, (float)0.75, edit);
		outputfolder.addView(IPageLayout.ID_PROBLEM_VIEW);
		outputfolder.addPlaceholder(IPageLayout.ID_BOOKMARKS);
		outputfolder.addPlaceholder(IPageLayout.ID_TASK_LIST);
		outputfolder.addPlaceholder(IProgressConstants.PROGRESS_VIEW_ID);
//		outputfolder.addPlaceholder(IConsoleConstants.ID_CONSOLE_VIEW);     // Later?
		
		// Outline views
		IFolderLayout outlinefolder = layout.createFolder("right", IPageLayout.RIGHT, (float)0.75, edit);
		outlinefolder.addView(IPageLayout.ID_OUTLINE);
		outlinefolder.addView(IDEConstants.INSTANCE_OUTLINE_VIEW_ID);
		
		// Actions
		layout.addActionSet(IPageLayout.ID_NAVIGATE_ACTION_SET);
	}

}
