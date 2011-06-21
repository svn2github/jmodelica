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
package org.jmodelica.ide.editor;

import org.eclipse.jface.action.IContributionManager;
import org.eclipse.jface.action.ICoolBarManager;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.jface.action.Separator;
import org.eclipse.ui.IActionBars;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchActionConstants;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.actions.LabelRetargetAction;
import org.eclipse.ui.actions.RetargetAction;
import org.eclipse.ui.texteditor.BasicTextEditorActionContributor;
import org.eclipse.ui.texteditor.ITextEditor;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.ui.ImageLoader;


/**
 * Needed by Editor, used to add editor actions.
 */
public class EditorContributor extends BasicTextEditorActionContributor {

private static final String[] ACTION_IDS = { 
    IDEConstants.ACTION_ERROR_CHECK_ID,
    IDEConstants.ACTION_COMPILE_FMU_ID,
    IDEConstants.ACTION_TOGGLE_ANNOTATIONS_ID,
    IDEConstants.ACTION_FORMAT_REGION_ID, 
//    IDEConstants.ACTION_FOLLOW_REFERENCE_ID, 
    IDEConstants.ACTION_TOGGLE_COMMENT_ID };

private LabelRetargetAction errorCheckAction;
private LabelRetargetAction compileFMUAction;
private RetargetAction toggleAnnotationsAction;
private LabelRetargetAction formatRegionAction;
//private LabelRetargetAction followReferenceAction;
private LabelRetargetAction toggleCommentAction;

private RetargetAction[] retargetActions;

public EditorContributor() {
    errorCheckAction = new EditorLabelRetargetAction(IDEConstants.ACTION_ERROR_CHECK_ID,
            IDEConstants.ACTION_ERROR_CHECK_TEXT);
    errorCheckAction.setImageDescriptor(ImageLoader.ERROR_CHECK_DESC);
    errorCheckAction.setDisabledImageDescriptor(ImageLoader.ERROR_CHECK_DIS_DESC);
    
    compileFMUAction = new EditorLabelRetargetAction(IDEConstants.ACTION_COMPILE_FMU_ID,
            IDEConstants.ACTION_COMPILE_FMU_TEXT);
    compileFMUAction.setImageDescriptor(ImageLoader.COMPILE_FMU_DESC);
    compileFMUAction.setDisabledImageDescriptor(ImageLoader.COMPILE_FMU_DIS_DESC);
    
    toggleAnnotationsAction = new EditorRetargetAction(
            IDEConstants.ACTION_TOGGLE_ANNOTATIONS_ID,
            IDEConstants.ACTION_TOGGLE_ANNOTATIONS_TEXT,
            RetargetAction.AS_CHECK_BOX);
    toggleAnnotationsAction.setImageDescriptor(ImageLoader.ANNOTATION_DESC);
    toggleAnnotationsAction.setDisabledImageDescriptor(ImageLoader.ANNOTATION_DIS_DESC);

    formatRegionAction = new LabelRetargetAction(
            IDEConstants.ACTION_FORMAT_REGION_ID,
            IDEConstants.ACTION_FORMAT_REGION_TEXT);

    toggleCommentAction = new LabelRetargetAction(
            IDEConstants.ACTION_TOGGLE_COMMENT_ID,
            IDEConstants.ACTION_TOGGLE_COMMENT_TEXT);
    
//    followReferenceAction = new LabelRetargetAction(
//            IDEConstants.ACTION_FOLLOW_REFERENCE_ID,
//            IDEConstants.ACTION_FOLLOW_REFERENCE_TEXT);
   
    retargetActions = new RetargetAction[] { 
            errorCheckAction,
            compileFMUAction,
            toggleAnnotationsAction, 
//            followReferenceAction,
            formatRegionAction,
            toggleCommentAction };
}

@Override
public void init(IActionBars bars, IWorkbenchPage page) {
    super.init(bars, page);
    for (RetargetAction a : retargetActions)
        page.addPartListener(a);
    doSetActiveEditor(page.getActiveEditor());
    IWorkbenchPart activePart = page.getActivePart();
    if (activePart != null) {
        for (RetargetAction a : retargetActions)
            a.partActivated(activePart);
    }
}

@Override
public void setActiveEditor(IEditorPart part) {
    doSetActiveEditor(part);
    super.setActiveEditor(part);
}

private void doSetActiveEditor(IEditorPart part) {
    ITextEditor editor = (part instanceof ITextEditor) ? (ITextEditor) part : null;
    IActionBars actionBars = getActionBars();
    for (int i = 0; i < ACTION_IDS.length; i++)
        actionBars.setGlobalActionHandler(ACTION_IDS[i], getAction(editor, ACTION_IDS[i]));
}

@Override
public void contributeToMenu(IMenuManager menu) {
    super.contributeToMenu(menu);
    IMenuManager editMenu = menu.findMenuUsingPath(IWorkbenchActionConstants.M_EDIT);
    editMenu.appendToGroup("additions", new Separator(IDEConstants.GROUP_EDIT_ID));
    editMenu.appendToGroup(IDEConstants.GROUP_EDIT_ID, toggleAnnotationsAction);
    editMenu.appendToGroup(IDEConstants.GROUP_EDIT_ID, formatRegionAction);
//    editMenu.appendToGroup(IDEConstants.GROUP_EDIT_ID, followReferenceAction);
    editMenu.appendToGroup(IDEConstants.GROUP_EDIT_ID, toggleCommentAction);
}

@Override
public void contributeToCoolBar(ICoolBarManager coolBarManager) {
    super.contributeToCoolBar(coolBarManager);
    contributeToToolOrCoolBar(coolBarManager);
}

@Override
public void contributeToToolBar(IToolBarManager toolBarManager) {
    super.contributeToToolBar(toolBarManager);
    contributeToToolOrCoolBar(toolBarManager);
}

private void contributeToToolOrCoolBar(IContributionManager barManager) {
    barManager.add(new Separator(IDEConstants.GROUP_MODELICA_ID));
    barManager.appendToGroup(IDEConstants.GROUP_MODELICA_ID, errorCheckAction);
    barManager.appendToGroup(IDEConstants.GROUP_MODELICA_ID, compileFMUAction);
    barManager.appendToGroup(IDEConstants.GROUP_MODELICA_ID, toggleAnnotationsAction);
}

@Override
public void dispose() {
    for (RetargetAction a : retargetActions) {
        getPage().removePartListener(a);
        a.dispose();
    }
    super.dispose();
}

// Temporary hack to make the retarget actions ignore other views than editors
// TODO: Find a solution with commands instead

public class EditorRetargetAction extends RetargetAction {
	
	private IEditorPart last;

	public EditorRetargetAction(String actionID, String text, int style) {
		super(actionID, text, style);
		last = null;
	}

	public void partActivated(IWorkbenchPart part) {
		if (part instanceof IEditorPart) {
			if (last != null)
				super.partDeactivated(part);
			last = (IEditorPart) part;
			super.partActivated(part);
		}
	}

	public void partDeactivated(IWorkbenchPart part) {
		super.partDeactivated(part);
	}
	
}

public class EditorLabelRetargetAction extends LabelRetargetAction {
	
	private IEditorPart last;

	public EditorLabelRetargetAction(String actionID, String text) {
		super(actionID, text);
	}

	public void partActivated(IWorkbenchPart part) {
		if (part instanceof IEditorPart) {
			if (last != null)
				super.partDeactivated(part);
			last = (IEditorPart) part;
			super.partActivated(part);
		}
	}

	public void partDeactivated(IWorkbenchPart part) {
		super.partDeactivated(part);
	}
	
}

}
