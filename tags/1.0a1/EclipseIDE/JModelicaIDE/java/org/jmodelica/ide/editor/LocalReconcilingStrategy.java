package org.jmodelica.ide.editor;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.reconciler.DirtyRegion;
import org.eclipse.jface.text.reconciler.IReconcilingStrategy;
import org.eclipse.jface.text.reconciler.IReconcilingStrategyExtension;

public class LocalReconcilingStrategy implements IReconcilingStrategy, IReconcilingStrategyExtension {
	private Editor editor;
	private	IDocument document;

	public LocalReconcilingStrategy(Editor editor) {
		this.editor = editor;
	}

	public void reconcile(IRegion partition) {
		editor.recompileLocal(document);
		
	}

	public void reconcile(DirtyRegion dirtyRegion, IRegion subRegion) {
		editor.recompileLocal(document);
	}

	public void setDocument(IDocument document) {
		this.document = document;
	}

	public void initialReconcile() {
		editor.recompileLocal(document);
	}

	public void setProgressMonitor(IProgressMonitor monitor) {
	}
}
