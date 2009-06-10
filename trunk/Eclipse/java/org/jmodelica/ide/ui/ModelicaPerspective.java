package org.jmodelica.ide.ui;

import org.eclipse.ui.IFolderLayout;
import org.eclipse.ui.IPageLayout;
import org.eclipse.ui.IPerspectiveFactory;
import org.eclipse.ui.progress.IProgressConstants;
import org.jmodelica.ide.Constants;

public class ModelicaPerspective implements IPerspectiveFactory {

	public void createInitialLayout(IPageLayout layout) {
		String edit = layout.getEditorArea();
		layout.setEditorAreaVisible(true);
		
		// Shortcuts
		layout.addPerspectiveShortcut(Constants.PERSPECTIVE_ID);
		
		layout.addNewWizardShortcut(Constants.WIZARD_FILE_ID);
		layout.addNewWizardShortcut(Constants.WIZARD_PROJECT_ID);
		layout.addNewWizardShortcut("org.eclipse.ui.wizards.new.folder");
		layout.addNewWizardShortcut("org.eclipse.ui.wizards.new.file");
		layout.addNewWizardShortcut("org.eclipse.ui.editors.wizards.UntitledTextFileWizard");
		
		layout.addShowViewShortcut("org.eclipse.ui.navigator.ProjectExplorer");
		layout.addShowViewShortcut(Constants.INSTANCE_OUTLINE_VIEW_ID);
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
		outlinefolder.addView(Constants.INSTANCE_OUTLINE_VIEW_ID);
		
		// Actions
		layout.addActionSet(IPageLayout.ID_NAVIGATE_ACTION_SET);
	}

}
