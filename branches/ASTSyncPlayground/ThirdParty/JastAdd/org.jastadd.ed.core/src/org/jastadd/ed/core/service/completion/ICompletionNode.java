package org.jastadd.ed.core.service.completion;

import java.util.Collection;

import org.eclipse.jface.text.contentassist.ICompletionProposal;

public interface ICompletionNode {

	public Collection<ICompletionProposal> completionProposals(int offset);
	
}
