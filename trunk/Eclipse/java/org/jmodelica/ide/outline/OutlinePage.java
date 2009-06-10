package org.jmodelica.ide.outline;

import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.ViewerComparator;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.texteditor.AbstractTextEditor;
import org.eclipse.ui.texteditor.ITextEditor;
import org.jastadd.plugin.compiler.ast.IJastAddNode;
import org.jastadd.plugin.ui.view.AbstractBaseContentOutlinePage;
import org.jmodelica.ast.ASTNode;
import org.jmodelica.ide.editor.Editor;

public abstract class OutlinePage extends AbstractBaseContentOutlinePage {

	private OutlineItemComparator comparator;

	public OutlinePage(AbstractTextEditor editor) {
		super(editor);
	}

	@Override
	protected void openFileForNode(IJastAddNode node) {
		// This method is never called, and there seems to be no situation that it should be.
	}

	@Override
	protected void highlightNodeInEditor(IJastAddNode node) {
		IWorkbenchWindow window = PlatformUI.getWorkbench().getActiveWorkbenchWindow();
		IWorkbenchPage page = window.getActivePage();
		IEditorPart editor = page.getActiveEditor();
		if (editor instanceof Editor && node instanceof ASTNode) 
			((Editor) editor).selectNode((ASTNode) node);
	}

	@Override
	public void createControl(Composite parent) {
		super.createControl(parent);
		TreeViewer viewer = getTreeViewer();
		viewer.setComparator(getComparator());
		update();
	}

	protected ViewerComparator getComparator() {
		if (comparator == null)
			comparator = new OutlineItemComparator();
		return comparator;
	}

}