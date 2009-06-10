package org.jmodelica.ide.outline;

import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.ISelectionProvider;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.part.IPage;
import org.eclipse.ui.part.IPageBookViewPage;
import org.eclipse.ui.part.IPageSite;
import org.eclipse.ui.part.MessagePage;
import org.eclipse.ui.part.PageBook;
import org.eclipse.ui.part.PageBookView;
import org.eclipse.ui.views.contentoutline.IContentOutlinePage;
import org.jmodelica.ide.editor.Editor;

public abstract class OutlineView extends PageBookView implements ISelectionProvider, ISelectionChangedListener {

    private String defaultText = "An outline is not available."; 

	protected abstract IContentOutlinePage getOutlinePage(Editor part);

	@Override
	protected IPage createDefaultPage(PageBook book) {
        MessagePage page = new MessagePage();
        initPage(page);
        page.createControl(book);
        page.setMessage(defaultText);
        return page;
	}

	@Override
	protected PageRec doCreatePage(IWorkbenchPart part) {
		if (part instanceof Editor) {
			IContentOutlinePage page = getOutlinePage((Editor) part);
			if (page instanceof IPageBookViewPage) 
				initPage((IPageBookViewPage) page);
			page.createControl(getPageBook());
			return new PageRec(part, page);
		}
        // There is no content outline
        return null;
	}

	@Override
	protected void doDestroyPage(IWorkbenchPart part, PageRec rec) {
        IContentOutlinePage page = (IContentOutlinePage) rec.page;
        page.dispose();
        rec.dispose();
	}

	@Override
	protected IWorkbenchPart getBootstrapPart() {
        IWorkbenchPage page = getSite().getPage();
        if (page != null) 
			return page.getActiveEditor();
       return null;
	}

	@Override
	protected boolean isImportant(IWorkbenchPart part) {
		return part instanceof Editor;
	}

	public void addSelectionChangedListener(ISelectionChangedListener listener) {
        getSelectionProvider().addSelectionChangedListener(listener);
	}

	public ISelection getSelection() {
		return getSelectionProvider().getSelection();
	}

	@Override
	public void partBroughtToTop(IWorkbenchPart part) {
		partActivated(part);
	}

	public void removeSelectionChangedListener(
			ISelectionChangedListener listener) {
		getSelectionProvider().removeSelectionChangedListener(listener);
	}

	public void setSelection(ISelection selection) {
		getSelectionProvider().setSelection(selection);
	}

	public void selectionChanged(SelectionChangedEvent event) {
		getSelectionProvider().selectionChanged(event);
	}

    /**
     * Extends the behavior of parent to use the current page as a selection provider.
     * 
     * @param pageRec the page record containing the page to show
     */
    protected void showPageRec(PageRec pageRec) {
        IPageSite pageSite = getPageSite(pageRec.page);
        ISelectionProvider provider = pageSite.getSelectionProvider();
        if (provider == null && (pageRec.page instanceof IContentOutlinePage)) {
			// This means that the page did not set a provider during its initialization 
            // so for backward compatibility we will set the page itself as the provider.
            pageSite.setSelectionProvider((IContentOutlinePage) pageRec.page);
		}
        super.showPageRec(pageRec);
    }

}
