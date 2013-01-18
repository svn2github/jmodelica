package org.jastadd.ed.core;

import org.eclipse.jface.text.DefaultInformationControl;
import org.eclipse.jface.text.IAutoEditStrategy;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IInformationControl;
import org.eclipse.jface.text.IInformationControlCreator;
import org.eclipse.jface.text.contentassist.ContentAssistant;
import org.eclipse.jface.text.contentassist.IContentAssistant;
import org.eclipse.jface.text.reconciler.IReconciler;
import org.eclipse.jface.text.reconciler.IReconcilingStrategy;
import org.eclipse.jface.text.reconciler.MonoReconciler;
import org.eclipse.jface.text.source.DefaultAnnotationHover;
import org.eclipse.jface.text.source.IAnnotationHover;
import org.eclipse.jface.text.source.ISourceViewer;
import org.eclipse.jface.text.source.SourceViewerConfiguration;
import org.eclipse.swt.widgets.Shell;
import org.jastadd.ed.core.model.node.ILocalRootHandle;
import org.jastadd.ed.core.service.completion.CompletionProcessor;
import org.jastadd.ed.core.util.ColorRegistry;

public class ViewerConfiguration extends SourceViewerConfiguration {
	
	protected IReconcilingStrategy fStrategy;
	protected IReconciler fReconciler;
	protected final ILocalRootHandle fRootHandle;
	
	public ViewerConfiguration(ILocalRootHandle proxy, ICompiler compiler) {
		fRootHandle = proxy;
		fStrategy = new ReconcilingStrategy(fRootHandle, compiler);
	}
	
	
	/*
	 * CONTENT ASSIST
	 */

	@Override
	public IContentAssistant getContentAssistant(ISourceViewer sourceViewer) {
		ContentAssistant assistant = new ContentAssistant();
		assistant.setShowEmptyList(true);
		assistant.setInformationControlCreator(new IInformationControlCreator() {
			public IInformationControl createInformationControl(Shell parent) {
				return new DefaultInformationControl(parent, "status", null);
			}
		});
		CompletionProcessor processor = new CompletionProcessor(fRootHandle);
		fRootHandle.addListener(processor);
		assistant.setContentAssistProcessor(processor, IDocument.DEFAULT_CONTENT_TYPE);
		assistant.enableAutoActivation(true);
		assistant.setAutoActivationDelay(1000);
		assistant.setProposalPopupOrientation(IContentAssistant.PROPOSAL_OVERLAY);
		assistant.setProposalSelectorBackground(ColorRegistry.instance().getColor(ColorRegistry.COLOR_LIGHT_YELLOW));
		assistant.setContextInformationPopupOrientation(IContentAssistant.CONTEXT_INFO_ABOVE);
		return assistant;
	}


	 
	/*
	 * LOCAL MODEL
	 * 
	 * Rebuilding of the local model
	 */
	

	@Override
	public IReconciler getReconciler(ISourceViewer sourceViewer) {
		if (fReconciler == null) {
			fReconciler = new MonoReconciler(fStrategy, false);
		}
		return fReconciler;
	}

	
	/*
	 * ANNOTATION HOVER
	 * 
	 * Hovers over e.g., error markers displaying the message in the marker
	 */
	
	@Override
	public IAnnotationHover getAnnotationHover(ISourceViewer sourceViewer) {
		return new DefaultAnnotationHover();
	}
	
	
	/*
	 * AUTO EDIT
	 */
	
	@Override
	public IAutoEditStrategy[] getAutoEditStrategies(
			ISourceViewer sourceViewer, String contentType) {	
		return super.getAutoEditStrategies(sourceViewer, contentType);
	}
	
	

}
