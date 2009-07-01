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
import org.jmodelica.ide.Constants;
import org.jmodelica.ide.ui.ImageLoader;

/**
 * Needed by Editor, used to add editor actions.
 * @author emma
 * 
 */
public class EditorContributor extends BasicTextEditorActionContributor {

	private static final String[] ACTIONS = { Constants.ACTION_ERROR_CHECK_ID, Constants.ACTION_TOGGLE_ANNOTATIONS_ID };
	private LabelRetargetAction errorCheckAction;
	private RetargetAction toggleAnnotationsAction;
	private RetargetAction[] retargetActions;

	public EditorContributor() {
		errorCheckAction = new LabelRetargetAction(Constants.ACTION_ERROR_CHECK_ID, Constants.ACTION_ERROR_CHECK_TEXT);
		errorCheckAction.setImageDescriptor(ImageLoader.ERROR_CHECK_DESC);
		errorCheckAction.setDisabledImageDescriptor(ImageLoader.ERROR_CHECK_DIS_DESC);
		toggleAnnotationsAction = new RetargetAction(Constants.ACTION_TOGGLE_ANNOTATIONS_ID, 
				Constants.ACTION_TOGGLE_ANNOTATIONS_TEXT, RetargetAction.AS_CHECK_BOX);
		toggleAnnotationsAction.setImageDescriptor(ImageLoader.ANNOTATION_DESC);
		toggleAnnotationsAction.setDisabledImageDescriptor(ImageLoader.ANNOTATION_DIS_DESC);
		
		retargetActions = new RetargetAction[] { errorCheckAction, toggleAnnotationsAction };
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
		for (int i = 0; i < ACTIONS.length; i++)
			actionBars.setGlobalActionHandler(ACTIONS[i], getAction(editor, ACTIONS[i]));
	}

	@Override
	public void contributeToMenu(IMenuManager menu) {
		// TODO Auto-generated method stub
		super.contributeToMenu(menu);
		IMenuManager editMenu= menu.findMenuUsingPath(IWorkbenchActionConstants.M_EDIT);
		editMenu.add(new Separator(Constants.GROUP_ERROR_ID));
		editMenu.appendToGroup(Constants.GROUP_ERROR_ID, errorCheckAction);
		editMenu.appendToGroup(Constants.GROUP_ERROR_ID, toggleAnnotationsAction);
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
		barManager.add(new Separator(Constants.GROUP_MODELICA_ID));
		barManager.appendToGroup(Constants.GROUP_MODELICA_ID, errorCheckAction);
		barManager.appendToGroup(Constants.GROUP_MODELICA_ID, toggleAnnotationsAction);
	}

	@Override
	public void dispose() {
		for (RetargetAction a : retargetActions) {
			getPage().removePartListener(a);
			a.dispose();
		}
		super.dispose();
	}

}
