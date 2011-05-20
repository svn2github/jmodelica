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

import java.util.ArrayList;

import org.eclipse.jface.viewers.IBaseLabelProvider;
import org.eclipse.jface.viewers.IElementComparer;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.TreePath;
import org.eclipse.jface.viewers.TreeSelection;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.ViewerComparator;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.texteditor.AbstractTextEditor;
import org.jastadd.plugin.compiler.ast.IASTNode;
import org.jastadd.plugin.compiler.ast.IJastAddNode;
import org.jastadd.plugin.ui.view.AbstractBaseContentOutlinePage;
import org.jastadd.plugin.ui.view.JastAddLabelProvider;
import org.jmodelica.ide.editor.Editor;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.BaseNode;
import org.jmodelica.modelica.compiler.SourceRoot;

public abstract class OutlinePage extends AbstractBaseContentOutlinePage {
	
	public static final JastAddLabelProvider JASTADD_LABEL = new JastAddLabelProvider();
	public static final ASTContentProvider JASTADD_CONTENT = new ASTContentProvider();

	private OutlineItemComparator comparator;
	private IElementComparer comparer;
	protected boolean selecting;
	private IBaseLabelProvider labelProvider;
	private UpdatingContentProvider contentProvider;

	public OutlinePage(AbstractTextEditor editor) {
		super(editor);
		selecting = false;
	}

	@Override
	protected void openFileForNode(IJastAddNode node) {
		// This method is never called, and there seems to be 
	    // no situation that it should be.
	}

	@Override
	public void highlightNodeInEditor(IJastAddNode node) {
		if (!selecting) {
			IWorkbenchWindow window = PlatformUI.getWorkbench().getActiveWorkbenchWindow();
			IWorkbenchPage page = window.getActivePage();
			IEditorPart editor = page.getActiveEditor();
			if (editor instanceof Editor && node instanceof ASTNode<?>) 
				((Editor) editor).selectNode((ASTNode) node);
		}
	}

	@Override
	public void createControl(Composite parent) {
		super.createControl(parent);
		TreeViewer viewer = getTreeViewer();
		viewer.setComparator(getComparator());
		viewer.setComparer(getComparer());
		update();
	}

	private IElementComparer getComparer() {
		if (comparer == null)
			comparer = new NameComparer();
		return comparer;
	}

	protected ViewerComparator getComparator() {
		if (comparator == null)
			comparator = new OutlineItemComparator();
		return comparator;
	}

	protected IBaseLabelProvider getLabelProvider() {
		if (labelProvider == null)
			labelProvider = createLabelProvider();
		return labelProvider;
	}

	protected IBaseLabelProvider createLabelProvider() {
		return JASTADD_LABEL;
	}

	protected ITreeContentProvider getContentProvider() {
		if (contentProvider == null)
			contentProvider = new UpdatingContentProvider(createContentProvider());
		return contentProvider;
	}

	protected ITreeContentProvider createContentProvider() {
		return JASTADD_CONTENT;
	}

	/**
	 * Updates the entire tree, keeping selection and open branches.
	 */
	public void update() {
		update(null);
	}

	/**
	 * Updates a part of the tree, keeping selection and open branches.
	 * 
	 * @param node  the node to update, or <code>null</code> to update entire tree
	 */
	public void update(Object node) {
        TreeViewer viewer = getTreeViewer();
		if (viewer != null) {
			Control control= viewer.getControl();
			if (control != null && !control.isDisposed()) {
				control.setRedraw(false);
				ISelection selection = viewer.getSelection();
				TreePath[] paths = viewer.getExpandedTreePaths();
				
				if (node == null) {
					viewer.setInput(fRoot); 
					rootChanged(viewer);
				} else {
					viewer.refresh(node);
				}
				
				if (paths.length > 0)
					viewer.setExpandedTreePaths(paths);
				select(selection);
				control.setRedraw(true);
			}
		}
	}
	
	public void updateAST(IASTNode ast) {
		// Copy cached outline children to new root
		if (ast instanceof BaseNode && fRoot instanceof BaseNode)
			((BaseNode) ast).copyCachedOutlineFrom((BaseNode) fRoot);
		super.updateAST(ast);
	}

	protected abstract void rootChanged(TreeViewer viewer);

	public void select(ASTNode<?> node) {
		TreeSelection sel = (node != null) ? 
				new TreeSelection(pathFromNode(node)) : 
				new TreeSelection();
		select(sel);
	}

	private void select(ISelection sel) {
		selecting = true;
		TreeViewer viewer = getTreeViewer();
		if (viewer != null) 
			viewer.setSelection(sel, true);
		selecting = false;
	}

	private TreePath pathFromNode(Object node) {
		ArrayList<Object> list = new ArrayList<Object>();
		ITreeContentProvider provider = getContentProvider();
		while (node != null && node != fRoot) {
			list.add(node);
			node = provider.getParent(node);
		}
		int n = list.size();
		Object[] res = new Object[n];
		for (int i = 0; i < n; i++)
			res[i] = list.get(n - i - 1);
		return new TreePath(res);
	}

	public class NameComparer implements IElementComparer {

		public boolean equals(Object a, Object b) {
			return name(a).equals(name(b));
		}

		public int hashCode(Object element) {
			return name(element).hashCode();
		}

		private String name(Object element) {
			if (element == null)
				return "";
			if (element instanceof ASTNode)
				return ((ASTNode) element).outlineId();
			return element.toString();
		}

	}
}