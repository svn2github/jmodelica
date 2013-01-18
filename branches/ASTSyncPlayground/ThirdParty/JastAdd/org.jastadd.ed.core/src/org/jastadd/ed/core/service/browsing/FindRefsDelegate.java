package org.jastadd.ed.core.service.browsing;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.OperationCanceledException;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.search.ui.ISearchQuery;
import org.eclipse.search.ui.ISearchResult;
import org.eclipse.search.ui.NewSearchUI;
import org.eclipse.ui.IEditorActionDelegate;
import org.eclipse.ui.IEditorPart;
import org.jastadd.ed.core.Activator;
import org.jastadd.ed.core.Editor;
import org.jastadd.ed.core.model.node.ILocalRootHandle;
import org.jastadd.ed.core.model.node.ILocalRootNode;
import org.jastadd.ed.core.model.node.ITextViewNode;
import org.jastadd.ed.core.search.SearchResult;
import org.jastadd.ed.core.service.view.ITreeNode;

public class FindRefsDelegate implements IEditorActionDelegate {

	protected IEditorPart fEditorPart;
	protected ISelection fSelection;
	
	@Override
	public void run(IAction action) {
		if (fEditorPart instanceof Editor && fSelection instanceof ITextSelection) {
			Editor editor = (Editor)fEditorPart;
			ILocalRootHandle rootHandle = editor.getLocalRootHandle();
			int offset = ((ITextSelection)fSelection).getOffset();
			if (offset >= 0 && rootHandle.isInCompilableProject()) {
				
				ArrayList<ITextViewNode> result = new ArrayList<ITextViewNode>();
				List<ITreeNode> convertedResult = new ArrayList<ITreeNode>();
				StringBuffer buf = new StringBuffer();
				buf.append("Results for \"Find References\"");
				try  {
					rootHandle.getLock().acquire();
					ILocalRootNode localRoot = rootHandle.getLocalRoot();
					if (localRoot instanceof ITextViewNode) {
						ITextViewNode node = ((ITextViewNode)localRoot).findNodeForOffset(offset);
						//System.out.println("FindRefsDelegate: Found node of type " + (node == null ? "null" : node.getClass().getName()));
						if (node instanceof IBrowsingNode) {
							buf.append(" of " + ((IBrowsingNode) node).browsingLabel());
							IBrowsingNode browsingNode = (IBrowsingNode)node;
							IBrowsingNode declNode = browsingNode.browsingDecl();
							//System.out.println("FindRefsDelegate: Found decl " + (declNode == null ? "null" : declNode.getClass().getName()));
							if (declNode != null) {
								for (IBrowsingNode refNode : declNode.browsingRefs()) {
									result.add(refNode);
								}
							}
						}
					}
					convertedResult = BrowsingNode.convertResult(result);
				} finally {
					rootHandle.getLock().release();
				}
				FindRefsQuery query = new FindRefsQuery(rootHandle, offset);
				SearchResult searchResult = new SearchResult(query, buf.toString()); 
				searchResult.addResult(convertedResult);
				query.setResult(searchResult);
				
				NewSearchUI.runQueryInBackground(query);
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
	
	
	
	private class FindRefsQuery implements ISearchQuery {

		private ILocalRootHandle fRootHandle;
		private int fOffset;
		private SearchResult fResult;
		
		public FindRefsQuery(ILocalRootHandle handle, int offset) {
			fRootHandle = handle;
			fOffset = offset;
			fResult = new SearchResult(this);
		}
		
		public void setResult(SearchResult result) {
			fResult = result;
		}
		
		
		@Override
		public IStatus run(IProgressMonitor monitor) throws OperationCanceledException {
			/*
			ArrayList<ITextViewNode> result = new ArrayList<ITextViewNode>();
			fProxy.LOCK.acquire();
			ITextViewNode node = fProxy.getCompilationUnit().findNodeForOffset(fOffset);
			System.out.println("AspectFindRefsDelegate: Found node of type " + (node == null ? "null" : node.getClass().getName()));
			if (node instanceof IBrowsingNode) {
				IBrowsingNode browsingNode = (IBrowsingNode)node;
				IBrowsingNode declNode = browsingNode.browsingDecl();
				System.out.println("AspectFindRefsDelegate: Found decl " + (declNode == null ? "null" : declNode.getClass().getName()));
				if (declNode != null) {
					for (IBrowsingNode refNode : declNode.browsingRefs()) {
						result.add(refNode);
					}
				}
			}
			List<SearchResultNode> convertedResult = SearchResultNode.convertResult(result);
			fProxy.LOCK.release();	
			fResult.addResult(convertedResult);
			*/
			return new Status(IStatus.OK, Activator.PLUGIN_ID, "Find references search OK");
		}

		@Override
		public String getLabel() {
			return "Find references";
		}

		@Override
		public boolean canRerun() {
			return false;
		}

		@Override
		public boolean canRunInBackground() {
			return true;
		}

		@Override
		public ISearchResult getSearchResult() {
			return fResult;
		}
		
	}

}
