package org.jmodelica.ide.namecomplete;

import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import org.eclipse.jface.text.contentassist.CompletionProposal;
import org.eclipse.jface.text.contentassist.ICompletionProposal;


/**
 * Makes a list completion proposals suitable for use in the Eclipse Content
 * Assist.
 * 
 * @author philip
 */
public class CompletionProposalsArray {

final Set<ICompletionProposal> icps;

final static Comparator<ICompletionProposal> proposalComparator = 
    new Comparator<ICompletionProposal>() {
    public int compare(ICompletionProposal o1, ICompletionProposal o2) {
        return o1.getDisplayString().compareTo(o2.getDisplayString());
    }
};

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
    
    icps = 
        new TreeSet<ICompletionProposal>(proposalComparator);
    
    for (CompletionNode completion : completions) {

        icps.add(
            new CompletionProposal(
                completion.completionName(),
                offset - filterLength, 
                filterLength, 
                completion.completionName().length(),
                completion.completionImage(),
                completion.completionName() + completion.completionDoc(),
                null,
                null));
    }

    
}

public ICompletionProposal[] toArray() {
    return icps.toArray(new ICompletionProposal[]{});
}

}
