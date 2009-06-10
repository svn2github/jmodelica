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

	public EditorContributor() {
		errorCheckAction = new LabelRetargetAction(Constants.ACTION_ERROR_CHECK_ID, Constants.ACTION_ERROR_CHECK_TEXT);
		errorCheckAction.setImageDescriptor(ImageLoader.ERROR_CHECK_DESC);
		errorCheckAction.setDisabledImageDescriptor(ImageLoader.ERROR_CHECK_DIS_DESC);
		toggleAnnotationsAction = new RetargetAction(Constants.ACTION_TOGGLE_ANNOTATIONS_ID, 
				Constants.ACTION_TOGGLE_ANNOTATIONS_TEXT, LabelRetargetAction.AS_CHECK_BOX);
		toggleAnnotationsAction.setImageDescriptor(ImageLoader.ANNOTATION_DESC);
		toggleAnnotationsAction.setDisabledImageDescriptor(ImageLoader.ANNOTATION_DIS_DESC);
	}

	@Override
	public void init(IActionBars bars, IWorkbenchPage page) {
		super.init(bars, page);
		page.addPartListener(errorCheckAction);
		page.addPartListener(toggleAnnotationsAction);
			doSetActiveEditor(page.getActiveEditor());
		IWorkbenchPart activePart = page.getActivePart();
		if (activePart != null) {
			errorCheckAction.partActivated(activePart);
			toggleAnnotationsAction.partActivated(activePart);
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
		getPage().removePartListener(errorCheckAction);
		getPage().removePartListener(toggleAnnotationsAction);
		errorCheckAction.dispose();
		toggleAnnotationsAction.dispose();
		super.dispose();
	}

}
