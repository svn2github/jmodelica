package org.jastadd.ed.core.search;

import org.eclipse.jface.viewers.DoubleClickEvent;
import org.eclipse.jface.viewers.IDoubleClickListener;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.TableViewer;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.search.ui.ISearchResultPage;
import org.eclipse.search.ui.text.AbstractTextSearchViewPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Composite;
import org.jastadd.ed.core.model.node.IASTNode;
import org.jastadd.ed.core.model.node.ITextViewNode;
import org.jastadd.ed.core.service.view.ITreeNode;
import org.jastadd.ed.core.service.view.JastAddContentProvider;
import org.jastadd.ed.core.service.view.JastAddLabelProvider;
import org.jastadd.ed.core.util.EditorUtil;

public class SearchResultPage extends AbstractTextSearchViewPage implements ISearchResultPage {
	
	private SearchViewContentProvider fContentProvider;
	private JastAddLabelProvider fLabelProvider;
	private IDoubleClickListener fDoubleClickListener;
	
	//private JastAddSearchResult fInput;

	private TreeViewer fViewer;
	
	public SearchResultPage() {
		//super(AbstractTextSearchViewPage.FLAG_LAYOUT_TREE);
		fContentProvider = new SearchViewContentProvider();
		fLabelProvider = new JastAddLabelProvider();
		fDoubleClickListener = new DoubleClickListener();
	}
	
	
	@Override
	protected void clear() {
	/*	if (fContentProvider != null)
			fContentProvider.clear(); TODO not working? */
	}


	@Override
	protected void configureTableViewer(TableViewer viewer) {
	}
		
	
	protected class DoubleClickListener implements IDoubleClickListener {
		public void doubleClick(DoubleClickEvent event) {
			IStructuredSelection selection = (IStructuredSelection) event.getSelection();
			Object element = selection.getFirstElement();
			if(element instanceof ITreeNode) {
				ITreeNode node = (ITreeNode)element;	
				IASTNode astNode = node.getNode();
				if (astNode instanceof ITextViewNode)
					EditorUtil.selectInEditor((ITextViewNode)astNode);
			}
		}
	}
	
	
	@Override
	protected TreeViewer createTreeViewer(Composite parent) {
		fViewer = new TreeViewer(parent, SWT.MULTI | SWT.H_SCROLL | SWT.V_SCROLL);
		return fViewer;
	}
	
	

	@Override
	protected void configureTreeViewer(TreeViewer viewer) {
		viewer.setContentProvider(fContentProvider);
		viewer.setLabelProvider(fLabelProvider);
		viewer.addDoubleClickListener(fDoubleClickListener);
//		if (fInput != null)
//			viewer.setInput(fInput);
	}

	@Override
	protected void elementsChanged(Object[] objects) {
		if (fContentProvider != null) {
			//fContentProvider.elementsChanged(objects);//TODO not working?
			fViewer.getControl().setRedraw(true);
		}
	}

	
	protected class SearchViewContentProvider extends JastAddContentProvider {

		@Override
		public Object[] getElements(Object inputElement) {
			if (inputElement instanceof SearchResult) {
				return ((SearchResult)inputElement).getElements();
			}
			return super.getElements(inputElement);
		}
		
	}
}
