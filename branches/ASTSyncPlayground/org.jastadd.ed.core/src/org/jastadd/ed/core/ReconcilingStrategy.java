package org.jastadd.ed.core;

import java.util.Collection;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.reconciler.DirtyRegion;
import org.eclipse.jface.text.reconciler.IReconcilingStrategy;
import org.eclipse.jface.text.reconciler.IReconcilingStrategyExtension;
import org.jastadd.ed.core.model.node.ILocalRootHandle;
import org.jastadd.ed.core.model.node.ILocalRootNode;
import org.jastadd.ed.core.service.errors.ErrorMarker;
import org.jastadd.ed.core.service.errors.IError;
import org.jastadd.ed.core.service.errors.IErrorFeedbackNode;

public class ReconcilingStrategy implements IReconcilingStrategy,
		IReconcilingStrategyExtension {

	protected IDocument fDocument;
	protected final ILocalRootHandle fRootHandle;
	protected final ICompiler fCompiler;
	
	// TODO: use progress monitor
	protected IProgressMonitor fProgressMonitor;
	
	public ReconcilingStrategy(ILocalRootHandle handle, ICompiler compiler) {
		fRootHandle = handle;
		fCompiler = compiler;
	}
	
	@Override
	public void setProgressMonitor(IProgressMonitor monitor) {
		fProgressMonitor = monitor;
	}

	@Override
	public void initialReconcile() {
		recompileDocument();
	}

	@Override
	public void setDocument(IDocument document) {
		this.fDocument = document;
	}

	@Override
	public void reconcile(DirtyRegion dirtyRegion, IRegion subRegion) {
		recompileDocument();
	}

	@Override
	public void reconcile(IRegion partition) {
		recompileDocument();
	}

	
	protected void recompileDocument() {
		if (fDocument != null && fRootHandle != null) {
			try {
				fRootHandle.getLock().acquire();
				IFile file = fRootHandle.getFile();
				ILocalRootNode localRoot = fCompiler.compile(file, fDocument);
				localRoot.setFile(file);
				fRootHandle.setLocalRoot(localRoot);
				updateErrors(file, localRoot);
			} finally {
				fRootHandle.getLock().release();
			}
			fRootHandle.notifyListeners();
		}
	}
	
	protected void updateErrors(IFile file, ILocalRootNode root) {

		if (root instanceof IErrorFeedbackNode) {
			updateSyntaxErrors(file, (IErrorFeedbackNode)root);
			updateSemanticErrors(file, (IErrorFeedbackNode)root);
		}
	}
	
	protected void updateSyntaxErrors(IFile file, IErrorFeedbackNode root) {
		Collection<IError> errors  = root.syntaxErrors();
		ErrorMarker.removeAll(file, IError.SYNTAX_MARKER_ID);
		ErrorMarker.addAll(file, errors, IError.SYNTAX_MARKER_ID);
	}
	
	protected void updateSemanticErrors(IFile file, IErrorFeedbackNode root) {
		Collection<IError> errors  = root.semanticErrors();
		ErrorMarker.removeAll(file, IError.MARKER_ID);
		ErrorMarker.addAll(file, errors, IError.MARKER_ID);
	}

}
