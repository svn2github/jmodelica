package org.jastadd.ed.core.search;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.search.ui.ISearchQuery;
import org.eclipse.search.ui.SearchResultEvent;
import org.eclipse.search.ui.text.AbstractTextSearchResult;
import org.eclipse.search.ui.text.IEditorMatchAdapter;
import org.eclipse.search.ui.text.IFileMatchAdapter;
import org.jastadd.ed.core.service.view.ITreeNode;

public class SearchResult extends AbstractTextSearchResult {

	protected ISearchQuery fQuery;
	protected ArrayList<ITreeNode> fResults;
	protected String fTitle;

	public SearchResult(ISearchQuery query) {
		fQuery = query;
		fResults  = new ArrayList<ITreeNode>();
		fTitle = "JastAdd Search Result";
	}
	
	public SearchResult(ISearchQuery query, String title) {
		this(query);
		fTitle = title;
	}

	public void addResult(List<ITreeNode> result) {
		fResults.addAll(result); 
		fireChange(new Event(this));
	}
	
	public ImageDescriptor getImageDescriptor() {
		return null;
	}

	public String getLabel() {
		return fTitle;
	}

	public ISearchQuery getQuery() {
		return fQuery;
	}

	public String getTooltip() {
		return "JastAdd Search Result Tooltip";
	}
	
	public Object[] getElements() {
		return fResults.toArray();
	}
	
	@Override
	public IEditorMatchAdapter getEditorMatchAdapter() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public IFileMatchAdapter getFileMatchAdapter() {
		// TODO Auto-generated method stub
		return null;
	}
	
	
	public static class Event extends SearchResultEvent {
		public Event(SearchResult result) {
			super(result);
		}
	}
}
