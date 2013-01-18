package org.jastadd.ed.core.service.view;

import org.eclipse.jface.text.AbstractInformationControl;
import org.eclipse.jface.text.IInformationControlExtension2;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.MouseAdapter;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Tree;
import org.jastadd.ed.core.model.node.ITextViewNode;
import org.jastadd.ed.core.model.node.ITreeViewNode;
import org.jastadd.ed.core.util.ColorRegistry;
import org.jastadd.ed.core.util.EditorUtil;

public class TreeViewInformationControl extends AbstractInformationControl implements IInformationControlExtension2 {

	private int fTreeStyle;
	protected Tree fTree;
	protected TreeViewer fTreeViewer;

	public TreeViewInformationControl(Shell parent, int shellStyle, 
			int treeStyle) {
		super(parent, true);
		this.fTreeStyle = treeStyle;
		create();
	}

	public TreeViewInformationControl(Shell parent) {
		this(parent, SWT.RESIZE, SWT.V_SCROLL | SWT.H_SCROLL);
	}
	
	@Override
	public void setInput(Object input) {
		if (input instanceof TreeNode) {
			TreeNode node = (TreeNode) input;
			fTreeViewer.setInput(new TreeNode.Wrapper(node));
			fTreeViewer.refresh();
			fTreeViewer.expandAll();
		}
	}
	
	@Override
	public void setFocus() {
		super.setFocus();
		fTree.setFocus();
	}

	@Override
	public boolean isFocusControl() {
		return fTreeViewer.getControl().isFocusControl();
	}
	
	@Override
	public boolean hasContents() {
		return fTreeViewer.getInput() != null;
	}

	@Override
	protected void createContent(Composite parent) {
		FillLayout fillLayout = new FillLayout(SWT.HORIZONTAL|SWT.VERTICAL);
		parent.setLayout(fillLayout);
		fTree = new Tree(parent, fTreeStyle);
		fTree.addSelectionListener(new SelectionListener() {
			public void widgetSelected(SelectionEvent e) { }
			public void widgetDefaultSelected(SelectionEvent e) {
				gotoSelectedElement();
				dispose();
			}
		});
		fTree.addMouseListener(new MouseAdapter() {
			public void mouseUp(MouseEvent e) {
				if (e.button != 1)
					return;
				if (fTree.getItem(new Point(e.x, e.y)) == null) 
					return;
				gotoSelectedElement();
				dispose();
			}
		});		
		fTree.setBackground(ColorRegistry.instance().getColor(ColorRegistry.COLOR_LIGHT_BLUE));
		fTreeViewer = new TreeViewer(fTree);
		fTreeViewer.setContentProvider(new TreeViewContentProvider());
		fTreeViewer.setLabelProvider(new TreeViewLabelProvider());
	}

	protected void gotoSelectedElement() {
		ISelection selection = fTreeViewer.getSelection();
		if (selection instanceof IStructuredSelection) {
			IStructuredSelection structSelect = (IStructuredSelection)selection;
			Object selectedObj = structSelect.getFirstElement();
			if (selectedObj instanceof TreeNode) {
				ITreeViewNode node = ((TreeNode)selectedObj).getNode();
				if (node instanceof ITextViewNode)
					EditorUtil.selectInEditor((ITextViewNode)node);
			}
		}
	}
}
