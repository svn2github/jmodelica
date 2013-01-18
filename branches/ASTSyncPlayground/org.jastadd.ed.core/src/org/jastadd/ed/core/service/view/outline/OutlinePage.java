package org.jastadd.ed.core.service.view.outline;

import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.part.IPageSite;
import org.eclipse.ui.views.contentoutline.ContentOutlinePage;
import org.jastadd.ed.core.Editor;
import org.jastadd.ed.core.model.node.IASTNode;
import org.jastadd.ed.core.model.node.ILocalRootHandle;
import org.jastadd.ed.core.model.node.ILocalRootNode;
import org.jastadd.ed.core.model.node.ILocalRootNodeListener;
import org.jastadd.ed.core.model.node.ITextViewNode;
import org.jastadd.ed.core.service.view.TreeViewContentProvider;
import org.jastadd.ed.core.service.view.TreeViewLabelProvider;

public class OutlinePage extends ContentOutlinePage implements ILocalRootNodeListener {

	protected Editor fEditor;
	protected TreeViewContentProvider fContentProvider;
	protected TreeViewLabelProvider fLabelProvider;
	protected ILocalRootHandle fRootHandle;
	protected OutlineNode fInput;

	public OutlinePage(Editor editor, ILocalRootHandle handle) {
		fEditor = editor;
		fRootHandle = handle;
		fContentProvider = new TreeViewContentProvider();
		fLabelProvider = new TreeViewLabelProvider();
	}

	@Override
	public void init(IPageSite pageSite) {
		super.init(pageSite);
		updateContent();
		updateViewer();
		fRootHandle.addListener(this);
	}

	@Override
	public void dispose() {
		super.dispose();
		fRootHandle.removeListener(this);
	}

	protected void updateContent() {
		if (fRootHandle.isInCompilableProject()) {
			try {
				fRootHandle.getLock().acquire();
				ILocalRootNode root = fRootHandle.getLocalRoot();
				if (root != null && root instanceof IOutlineNode) {
					IOutlineNode outlineNode = (IOutlineNode)root;
					fInput = OutlineNode.convertResult(outlineNode);	
				}
			} finally {
				fRootHandle.getLock().release();
			}
		}
	}

	protected void updateViewer() {
		TreeViewer viewer = getTreeViewer();
		if (viewer != null) {
			Control control = viewer.getControl();
			if (control != null && !control.isDisposed()) {
				control.setRedraw(false);
				viewer.setInput(fInput);
				viewer.setAutoExpandLevel(2);
				control.setRedraw(true);
			}
		}
	}

	@Override
	public void localRootChanged() {
		updateContent();
		updateViewer();
	}

	/*
	@Override
	public void astChanged(IASTChangeEvent e) {
		boolean change = false;
		IEditorNode node = e.getNode();
		if (node instanceof IEditorProjectNode) {
			IProject project = ((IEditorProjectNode)node).getProject();
			if (fFile != null && fFile.getProject().equals(project)) {
				fEditorNode = JastAddASTRegistry.instance().doLookup(fFile);
			}
			change = true;
		}
		else if (node instanceof IEditorFileNode) {
			IFile file = ((IEditorFileNode)node).getFile();
			if (fFile != null && fFile.equals(file)) {
				fEditorNode = JastAddASTRegistry.instance().doLookup(fFile);
			}
			change = true;
		}
		if (change)
			updateViewer();
	}
	 */

	// Called on start up

	public void createControl(Composite parent) {
		super.createControl(parent);
		TreeViewer viewer = getTreeViewer();
		viewer.setContentProvider(fContentProvider);
		viewer.setLabelProvider(fLabelProvider);
		viewer.addSelectionChangedListener(this);
		updateViewer();
	}





	/*
	 * SELECTED NODE mapped to CORRESPONDING TEXT 
	 */
	
	public void selectionChanged(SelectionChangedEvent event)
	{
	    super.selectionChanged(event);

	    // find out which item in tree viewer we have selected, and set
	    // highlight range accordingly
	    ISelection selection = event.getSelection();
	    if (selection.isEmpty()) {
	        fEditor.resetHighlightRange();
	    } else {

	        IStructuredSelection sel = (IStructuredSelection) selection;
	        OutlineNode node = (OutlineNode) sel.getFirstElement();
	        IASTNode astNode = node.getNode();

	        if (astNode instanceof ITextViewNode) {
	        	int start = -1;
	        	int end = -1;
	        	int length = 0;
	        	ITextViewNode textNode = (ITextViewNode)astNode;
	        	try {
	        		fRootHandle.getLock().acquire();
	        		start = textNode.startSelectionOffset();
	        		end = textNode.endSelectionOffset();
	        		length = end - start + 1;
	        	} finally {
	        		fRootHandle.getLock().release();
	        	}
	        	//System.out.println("[" + start + "," + end + "] - " + length);
	        	fEditor.selectAndReveal(0, 0);
	        	if (start >= 0 && end >= 0 && start <= end) {
	        		fEditor.selectAndReveal(start, length);
	        	} else if (start >= 0) {
	        		fEditor.selectAndReveal(start, 1);
	        	} else if (end >= 0) {
	        		fEditor.selectAndReveal(end, 1);
	        	}


			}
	    }
	}
	 

}
