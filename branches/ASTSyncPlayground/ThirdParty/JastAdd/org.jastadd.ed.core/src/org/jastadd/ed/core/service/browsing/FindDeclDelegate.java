package org.jastadd.ed.core.service.browsing;

import org.eclipse.jface.action.IAction;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.ui.IEditorActionDelegate;
import org.eclipse.ui.IEditorPart;
import org.jastadd.ed.core.Editor;
import org.jastadd.ed.core.model.node.ILocalRootHandle;
import org.jastadd.ed.core.model.node.ILocalRootNode;
import org.jastadd.ed.core.model.node.ITextViewNode;
import org.jastadd.ed.core.util.EditorUtil;

public class FindDeclDelegate implements IEditorActionDelegate {

	protected IEditorPart fEditorPart;
	protected ISelection fSelection;

	@Override
	public void run(IAction action) {
		if (fEditorPart instanceof Editor && fSelection instanceof ITextSelection) {
			Editor editor = (Editor)fEditorPart;
			int offset = ((ITextSelection)fSelection).getOffset();
			ILocalRootHandle rootHandle = editor.getLocalRootHandle();

			try {
				rootHandle.getLock().acquire();
				ILocalRootNode localRoot = rootHandle.getLocalRoot();
				if (localRoot instanceof ITextViewNode) {
					if (offset >= 0 && rootHandle.isInCompilableProject()) {
						ITextViewNode node = ((ITextViewNode)localRoot).findNodeForOffset(offset);
						//System.out.println("AspectFindDeclDelegate: Found node of type " + (node == null ? "null" : node.getClass().getName()));
						if (node instanceof IBrowsingNode) {
							IBrowsingNode browsingNode = (IBrowsingNode)node;
							IBrowsingNode declNode = browsingNode.browsingDecl();
							//System.out.println("AspectFindDeclDelegate: Found decl node " + (node == null ? "null" : node.getClass().getName()));
							if (declNode != null)
								EditorUtil.selectInEditor(declNode);	
						}
					}
				}

			} finally {
				rootHandle.getLock().release();
			}
		}
	}

	@Override
	public void selectionChanged(IAction action, ISelection selection) {
		fSelection = selection;
	}

	@Override
	public void setActiveEditor(IAction action, IEditorPart targetEditor) {
		fEditorPart = targetEditor;
	}

}
