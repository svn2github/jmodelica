package org.jmodelica.ide.namecomplete;

import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

import org.eclipse.jface.text.contentassist.CompletionProposal;
import org.eclipse.jface.text.contentassist.ICompletionProposal;


/**
 * Makes a list completion proposals suitable for use in the Eclipse Content
 * Assist.
 * 
 * @author philip
 */
public class CompletionProposalsArray {

final ICompletionProposal[] icps;

/**
 * Instantiate from list of CompletionNodes
 * 
 * @param completions completion nodes
 * @param filterLength length of filter used. (needed to be known for replacing
 *            filter string when completion has been made)
 * @param offset
 */
public CompletionProposalsArray(
        List<CompletionNode> completions, 
        int filterLength, 
        int offset) {
    
    icps = new ICompletionProposal[completions.size()];
    
    for (int i = 0; i < icps.length; i++) {

        CompletionNode completion = completions.get(i);
        
        icps[i] = 
            new CompletionProposal(
                completion.completionName(),
                offset - filterLength, 
                filterLength, 
                completion.completionName().length(),
                completion.completionImage(),
                completion.completionName() + completion.completionDoc(),
                null,
                null);
    }
    
    Comparator<ICompletionProposal> proposalComparator = 
        new Comparator<ICompletionProposal>() {
        public int compare(ICompletionProposal o1, ICompletionProposal o2) {
            return o1.getDisplayString().compareTo(o2.getDisplayString());
        }
    };
    
    Arrays.sort(icps, proposalComparator);
    
}

public ICompletionProposal[] toArray() {
    return icps;
}

}
