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

package org.jmodelica.ide.outline.cache;

import java.util.ArrayList;
import org.eclipse.jface.viewers.IBaseLabelProvider;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.texteditor.AbstractTextEditor;
import org.eclipse.ui.views.contentoutline.ContentOutlinePage;
import org.eclipse.jface.viewers.DoubleClickEvent;
import org.eclipse.jface.viewers.IDoubleClickListener;
import org.eclipse.jface.viewers.IElementComparer;
import org.eclipse.jface.viewers.TreePath;
import org.eclipse.jface.viewers.TreeSelection;
import org.eclipse.jface.viewers.ViewerComparator;
import org.eclipse.swt.dnd.Clipboard;
import org.eclipse.swt.dnd.DND;
import org.eclipse.swt.dnd.TextTransfer;
import org.eclipse.swt.dnd.Transfer;
import org.eclipse.ui.IActionBars;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.actions.ActionFactory;
import org.jmodelica.ide.outline.CopyClassAction;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.ide.helpers.hooks.IASTEditor;
import org.jmodelica.ide.outline.ClassCopySource;
import org.jmodelica.ide.outline.ClassDragListener;
import org.jmodelica.ide.outline.OutlineItemComparator;
import org.jmodelica.ide.outline.OutlineUpdateWorker;
import org.jmodelica.ide.sync.CachedASTNode;

public abstract class CachedOutlinePage extends ContentOutlinePage implements
		IDoubleClickListener {

	protected AbstractTextEditor fTextEditor;
	protected CachedASTNode fRoot;
	private ITreeContentProvider fContentProvider;
	private IBaseLabelProvider fLabelProvider;
	private OutlineItemComparator comparator;
	private IElementComparer comparer;
	protected boolean selecting;
	private boolean handleDoubleClick;

	public CachedOutlinePage(AbstractTextEditor editor) {
		super();
		fTextEditor = editor;
		fContentProvider = getContentProvider();
		fLabelProvider = getLabelProvider();
		selecting = false;
		handleDoubleClick = false;
	}

	protected ITreeContentProvider getContentProvider() {
		if (fContentProvider == null)
			fContentProvider = new CachedContentProvider();
		return fContentProvider;
	}

	protected IBaseLabelProvider getLabelProvider() {
		if (fLabelProvider == null)
			fLabelProvider = new CachedLabelProvider();
		return fLabelProvider;
	}

	@Override
	public void createControl(Composite parent) {
		super.createControl(parent);
		TreeViewer viewer = getTreeViewer();
		viewer.setContentProvider(fContentProvider);
		viewer.setLabelProvider(fLabelProvider);
		viewer.addSelectionChangedListener(this);
		viewer.setComparator(getComparator());
		viewer.setComparer(getComparer());
		// Set up drag & drop
		ClassCopySource copySource = new ClassCopySource(viewer);
		int ops = DND.DROP_COPY | DND.DROP_MOVE;
		Transfer[] transfers = new Transfer[] { TextTransfer.getInstance() };
		viewer.addDragSupport(ops, transfers, new ClassDragListener(copySource));

		// Set up copy/paste
		Clipboard clipboard = new Clipboard(getSite().getShell().getDisplay());
		IActionBars bars = getSite().getActionBars();
		bars.setGlobalActionHandler(ActionFactory.COPY.getId(),
				new CopyClassAction(copySource, clipboard));

		// if (fInput != null)
		// viewer.setInput(fInput);
		update();
	}

	@Override
	public void selectionChanged(SelectionChangedEvent event) {
		super.selectionChanged(event);
		ISelection selection = event.getSelection();
		if (selection.isEmpty() && fTextEditor != null)
			fTextEditor.resetHighlightRange();
		else {
			IStructuredSelection structSelect = (IStructuredSelection) selection;
			Object obj = structSelect.getFirstElement();
			if (obj instanceof CachedASTNode) {
				CachedASTNode node = (CachedASTNode) obj;

				highlightNodeInEditor(node);

				// openFileForNode(node);
			}
		}
	}

	/**
	 * Opens the file containing the given node
	 * 
	 * @param node
	 *            The node
	 */
	// protected abstract void openFileForNode(IJastAddNode node);

	/**
	 * @Override protected void openFileForNode(IJastAddNode node) { // This
	 *           method is never called, and there seems to be // no situation
	 *           that it should be. }
	 */

	/**
	 * Highlights the text corresponding to the given node
	 * 
	 * @param node
	 *            The node
	 */
	// protected abstract void highlightNodeInEditor(IJastAddNode node);

	/**
	 * Updates the AST shown by this outline page
	 * 
	 * @param ast
	 *            The AST to show
	 */
	public void updateAST(CachedASTNode ast) {
		// Copy cached outline children to new root
		// if (ast instanceof BaseNode && fRoot instanceof BaseNode)
		// ((BaseNode) ast).copyCachedOutlineFrom((BaseNode) fRoot);
		fRoot = ast;
		update();
	}

	/**
	 * Highlights the text corresponding to the given node
	 * 
	 * @param node
	 *            The node
	 */
	public void highlightNodeInEditor(CachedASTNode node) {
		if (!selecting) {
			IWorkbenchWindow window = PlatformUI.getWorkbench()
					.getActiveWorkbenchWindow();
			IWorkbenchPage page = window.getActivePage();
			IEditorPart editor = page.getActiveEditor();
			if (editor instanceof IASTEditor)
				((IASTEditor) editor).selectNode(true,
						node.containingFileName(),
						node.getSelectionNodeOffset(),
						node.getSelectionNodeLength());
		}
	}

	protected void setDoubleClickHandling(boolean active) {
		handleDoubleClick = active;
		if (active)
			getTreeViewer().addDoubleClickListener(this);
		else
			getTreeViewer().removeDoubleClickListener(this);
	}

	public void doubleClick(DoubleClickEvent event) {
		if (handleDoubleClick) {
			Object elem = Util.getSelected(event.getSelection());
			Util.openAndSelect(getSite().getPage(), elem);
			setFocus();
		}
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

	/**
	 * Updates the entire tree, keeping selection and open branches.
	 */
	public void update() {
		update(null);
	}

	/**
	 * Updates a part of the tree, keeping selection and open branches.
	 * 
	 * @param node
	 *            the node to update, or <code>null</code> to update entire tree
	 */
	public void update(Object node) {
		TreeViewer viewer = getTreeViewer();
		if (viewer != null) {
			Control control = viewer.getControl();
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

	protected abstract void rootChanged(TreeViewer viewer);

	public void select(CachedASTNode node) {
		if (node == null) {
			select(new TreeSelection());
		} else {
			TreePath path = pathFromNode(node);
			TreeViewer viewer = getTreeViewer();
			if (viewer != null && viewer.testFindItem(node) == null)
				OutlineUpdateWorker
						.expandAndSelect(this, getTreeViewer(), path);
			else
				select(new TreeSelection(path));
		}
	}

	public void select(ISelection sel) {
		selecting = true;
		TreeViewer viewer = getTreeViewer();
		if (viewer != null)
			viewer.setSelection(sel, true);
		selecting = false;
	}

	/**
	 * Check if the given node is in the tree of this page.
	 */
	public boolean contains(Object node) {
		ITreeContentProvider provider = getContentProvider();
		while (node != null && node != fRoot)
			node = provider.getParent(node);
		return node == fRoot;
	}

	/**
	 * Get the root of the AST shown in this page.
	 */
	public CachedASTNode getRoot() {
		return fRoot;
	}

	/**
	 * Return the path from the root of the tree to the given node.
	 */
	private TreePath pathFromNode(Object node) {
		ArrayList<Object> list = new ArrayList<Object>();
		ITreeContentProvider provider = getContentProvider();
		while (node != null && node != fRoot) {
			list.add(node);
			node = provider.getParent(node);
		}
		int n = list.size() + 1;
		Object[] res = new Object[n];
		for (int i = 1; i < n; i++)
			res[i] = list.get(n - i - 1);
		res[0] = fRoot;
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
			// getText() is not a unique ID. Viewer.refresh(node) will fail if
			// getText() is used.
			return element.toString();
		}
	}
}