package org.jastadd.ed.core.service.completion;

import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;

import org.eclipse.jface.text.ITextViewer;
import org.eclipse.jface.text.contentassist.ContextInformation;
import org.eclipse.jface.text.contentassist.ICompletionProposal;
import org.eclipse.jface.text.contentassist.IContentAssistProcessor;
import org.eclipse.jface.text.contentassist.IContextInformation;
import org.eclipse.jface.text.contentassist.IContextInformationValidator;
import org.jastadd.ed.core.model.node.IASTNode;
import org.jastadd.ed.core.model.node.ILocalRootHandle;
import org.jastadd.ed.core.model.node.ILocalRootNode;
import org.jastadd.ed.core.model.node.ILocalRootNodeListener;
import org.jastadd.ed.core.model.node.ITextViewNode;

public class CompletionProcessor implements IContentAssistProcessor, ILocalRootNodeListener {

	protected ILocalRootHandle fRootHandle; 
	
	public CompletionProcessor(ILocalRootHandle handle) {
		fRootHandle = handle;
	}
	
	@Override
	public ICompletionProposal[] computeCompletionProposals(ITextViewer viewer,int offset) {
		ICompletionProposal[] proposals = new ICompletionProposal[0];
		if (fRootHandle.isInCompilableProject()) {
			fRootHandle.getLock().acquire();
			try {
				ILocalRootNode localRoot = fRootHandle.getLocalRoot();
				if (localRoot instanceof ITextViewNode) {
					IASTNode node = ((ITextViewNode)localRoot).findNodeForOffset(offset-1);
					//System.out.println("CompletionProcessor: Found node of type " +(node == null ? "null" : node.getClass().getName()));
					
					while (!(node instanceof ICompletionNode) && !(node instanceof ILocalRootNode)) {
						node = node.getParent();
					}
					if (node instanceof ICompletionNode) {
						//System.out.println("CompletionProcessor: Found completion node of type " +(node == null ? "null" : node.getClass().getName()));
						ICompletionNode completionNode = (ICompletionNode)node;
						Collection<ICompletionProposal> completions = completionNode.completionProposals(offset);
						proposals = completions.toArray(new ICompletionProposal[]{});;
						Arrays.sort(proposals, new Comparator<ICompletionProposal>() {
							@Override
							public int compare(ICompletionProposal a, ICompletionProposal b) {
								return a.getDisplayString().compareTo(b.getDisplayString());
							}
						});
					}
				}
			} finally {
				fRootHandle.getLock().release();
			}
		}
		return proposals;
	}

	@Override
	public IContextInformation[] computeContextInformation(ITextViewer viewer,
			int offset) {
		return new ContextInformation[] {new ContextInformation(null, "context", "information")};
	}

	@Override
	public char[] getCompletionProposalAutoActivationCharacters() {
		return new char[] {'.'};
	}

	@Override
	public char[] getContextInformationAutoActivationCharacters() {
		return new char[]{'#'};
	}

	@Override
	public String getErrorMessage() {
		return "No information available";
	}

	@Override
	public IContextInformationValidator getContextInformationValidator() {
		return new IContextInformationValidator() {
			@Override
			public void install(IContextInformation info, ITextViewer viewer,
					int offset) {
			}
			@Override
			public boolean isContextInformationValid(int offset) {
				return true;
			}
		};
	}

	@Override
	public void localRootChanged() {
	}

}
