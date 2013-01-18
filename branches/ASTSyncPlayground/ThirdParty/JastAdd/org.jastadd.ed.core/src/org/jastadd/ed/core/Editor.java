package org.jastadd.ed.core;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.text.information.IInformationPresenter;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.texteditor.AbstractDecoratedTextEditor;
import org.eclipse.ui.views.contentoutline.IContentOutlinePage;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jastadd.ed.core.model.IGlobalRootRegistry;
import org.jastadd.ed.core.model.node.ILocalRootHandle;
import org.jastadd.ed.core.model.node.ILocalRootNode;
import org.jastadd.ed.core.model.node.LocalRootHandle;
import org.jastadd.ed.core.service.view.outline.OutlinePage;


public abstract class Editor extends AbstractDecoratedTextEditor implements IASTChangeListener {

	protected ILocalRootHandle fRootHandle;
	protected IGlobalRootRegistry fRegistry;
	protected ICompiler fCompiler;

	public Editor() {
	}

	protected abstract LocalRootHandle createInitialRootHandle();
	protected abstract IGlobalRootRegistry createLinkToGlobalRootRegistry();
	protected abstract ICompiler createLinkToCompiler();

	public ILocalRootHandle getLocalRootHandle() {
		return fRootHandle;
	}

	@Override
	protected void doSetInput(IEditorInput input) throws CoreException {
		super.doSetInput(input);
		if (input instanceof IFileEditorInput) {
			IFileEditorInput fileInput = (IFileEditorInput)input;
			IFile file  = fileInput.getFile();
			IProject project = file.getProject();
			boolean canCompileProject = fCompiler.canCompile(project);
			try {
				fRootHandle.getLock().acquire();
				fRootHandle.setFile(fileInput.getFile(), canCompileProject);
				ILocalRootNode[] localRoot = fRegistry.doLookup(file);
				if (localRoot.length == 1)
					fRootHandle.setLocalRoot(localRoot[0]);
			} finally {
				fRootHandle.getLock().release();
			}
			fRootHandle.notifyListeners(); //-- this should trigger the reconciler which will take care of building and notifying

		}
	}

	@Override
	public void astChanged(IASTChangeEvent e) {
		try {
			fRootHandle.getLock().acquire();
			IFile file = fRootHandle.getFile();
			ILocalRootNode[] localRoot = fRegistry.doLookup(file);
			if (localRoot.length == 1)
				fRootHandle.setLocalRootQuietly(localRoot[0]);
		} finally {
			fRootHandle.getLock().release();
		}
	}

	@Override
	protected void initializeEditor() {
		super.initializeEditor();
		fRootHandle = createInitialRootHandle();
		fRegistry = createLinkToGlobalRootRegistry();
		fCompiler = createLinkToCompiler();
		fRegistry.addListener(this);
	}

	@Override
	public void dispose() {
		super.dispose();
		fRegistry.removeListener(this);
	}


	/*
	 * QUICK TYPE HIERARCHY
	 */

	public void showInformationPresenter(IInformationPresenter presenter) {
		presenter.install(getSourceViewer());
		presenter.showInformation();
	}



	/*
	 * OUTLINE
	 */

	private OutlinePage outlinePage;

	@Override
	public Object getAdapter(Class required) {
		if (IContentOutlinePage.class.equals(required)) {
			if (outlinePage == null) {
				outlinePage = new OutlinePage(this, fRootHandle);
			}
			return outlinePage;
		}
		return super.getAdapter(required);
	}


}
