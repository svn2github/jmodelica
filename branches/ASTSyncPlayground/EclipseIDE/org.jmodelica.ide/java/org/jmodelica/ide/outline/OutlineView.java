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

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.ISelectionProvider;
import org.eclipse.jface.viewers.ITreeSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.part.IPage;
import org.eclipse.ui.part.IPageBookViewPage;
import org.eclipse.ui.part.IPageSite;
import org.eclipse.ui.part.IShowInTarget;
import org.eclipse.ui.part.MessagePage;
import org.eclipse.ui.part.PageBook;
import org.eclipse.ui.part.PageBookView;
import org.eclipse.ui.part.ShowInContext;
import org.eclipse.ui.views.contentoutline.IContentOutlinePage;
import org.jastadd.ed.core.model.node.IASTNode;
import org.jmodelica.ide.compiler.LocalRootNode;
import org.jmodelica.ide.compiler.ModelicaASTRegistry;
import org.jmodelica.ide.editor.Editor;
import org.jmodelica.modelica.compiler.ASTNode;

public abstract class OutlineView extends PageBookView 
implements ISelectionProvider, ISelectionChangedListener, IShowInTarget {

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
		IContentOutlinePage page = setupOutlinePage(part);
		if (page != null) 
			return new PageRec(part, page);
        // There is no content outline
        return null;
	}
	
	protected IContentOutlinePage setupOutlinePage(IWorkbenchPart part) {
		if (part instanceof Editor) {
			IContentOutlinePage page = getOutlinePage((Editor) part);
			if (page instanceof IPageBookViewPage) 
				initPage((IPageBookViewPage) page);
			page.createControl(getPageBook());
			return page;
		}
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

//	@Override
//	public void partBroughtToTop(IWorkbenchPart part) {
//		partActivated(part);
//	}

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

	public boolean show(ShowInContext context) {
		ISelection selection = context.getSelection();
		if (selection instanceof ITreeSelection) {
			// Pretty theoretic at this point, we don't support "show in" from any tree view
			ITreeSelection treeSel = (ITreeSelection) selection;
			if (treeSel.size() == 1) {
				Object elem = treeSel.getFirstElement();
				if (elem instanceof IASTNode)
					return selectNode((IASTNode) elem);
				else if (elem instanceof IFile)
					return selectNode(lookupASTForFile((IFile) elem));
			} else {
				// TODO: Does this work? probably not - but can't test yet
				IPage page = getCurrentPage();
				if (page instanceof OutlinePage) 
					((OutlinePage) page).select(selection);
			}
		} else if (context.getInput() instanceof IEditorInput) {
			IEditorInput input = (IEditorInput) context.getInput();
			IASTNode root = rootASTOfInput(input);
			if (root != null) {
				// TODO: Add needed methods to an interface instead
				ASTNode root2 = (ASTNode) root;
				if (selection instanceof ITextSelection) {
					ITextSelection textSel = (ITextSelection) selection;
					int offset = textSel.getOffset();
					int length = textSel.getLength();
					return selectNode(root2.containingClassDecl(offset, length));
				} else {
					return selectNode(root2.firstClassDecl());
				}
			}
		}
		return false;
	}

	/**
	 * Get the root of the AST that this view uses for the given file.
	 */
	protected IASTNode rootASTOfInput(IEditorInput input) {
		IEditorPart editor = getSite().getPage().findEditor(input);
		PageRec pageRec = getPageRec(editor);
		if (pageRec != null && pageRec.page instanceof OutlinePage) 
			return ((OutlinePage) pageRec.page).getRoot();
		else
			return null;
	}

	/**
	 * Look up the AST for a specific file in the AST registry.
	 * @param file  the file to look up in the registry
	 * @return
	 */
	private IASTNode lookupASTForFile(IFile file) {
		IProject project = file.getProject();
		String path = file.getRawLocation().toOSString();
		LocalRootNode fileNode = (LocalRootNode)ModelicaASTRegistry.getInstance().doLookup(file)[0];
		return fileNode.getDef();
	}

	/**
	 * Select and reveal the given node if it is in (the current page of) this view.
	 * @param node  the node to select
	 * @return <code>true</code> if selection was successful
	 */
	private boolean selectNode(IASTNode node) {
		IPage page = getCurrentPage();
		if (page instanceof OutlinePage) {
			OutlinePage page2 = (OutlinePage) page;
			if (page2.contains(node)) {
				page2.select((ASTNode) node);
				return true;
			}
		} 
		return false;
	}

}
