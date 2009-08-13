package org.jmodelica.ide.namecomplete;

import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ITextViewer;
import org.eclipse.jface.text.contentassist.CompletionProposal;
import org.eclipse.jface.text.contentassist.ContextInformationValidator;
import org.eclipse.jface.text.contentassist.ICompletionProposal;
import org.eclipse.jface.text.contentassist.IContentAssistProcessor;
import org.eclipse.jface.text.contentassist.IContextInformation;
import org.eclipse.jface.text.contentassist.IContextInformationValidator;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstNode;

/**
 * Completion processor for JModelica
 * 
 * @author philip
 *
 */
public class Completions implements IContentAssistProcessor {

public ASTNode<?> fRoot = null;

public Completions() {
    this(null);
}

public Completions(ASTNode<?> root) {
    this.fRoot = root;
}

/**
 * Comparator comparing completion proposals by display-string.
 * 
 * @author philip
 * 
 */
public final static Comparator<ICompletionProposal> proposalComparator = 
    new Comparator<ICompletionProposal>() {
    
    public int compare(ICompletionProposal o1, ICompletionProposal o2) {
        return o1.getDisplayString().compareTo(o2.getDisplayString());
    }
};

/**
 * Get context leading caret.
 * 
 * The context is determined by the text leading <code>caretOffset</code>. Two
 * values, context and filter are returned, where context represents a complete
 * qualified name, and filter represent a prefix.
 * 
 * E.g., leading text on the form 'a.b.prefix' results in
 * 
 * context = "a.b" 
 * filter = "prefix"
 * 
 * @param d document
 * @param caretOffset offset to lookup context at
 * @return a new Pair<String, String> containing context and filter.
 */
public Pair<String, String> getContext(IDocument d, int caretOffset) {
    
    String context, filter;

    try {

        int lineStart = d.getLineOffset(d.getLineOfOffset(caretOffset));

        String line = d.get(lineStart, caretOffset - lineStart).trim();
        String[] tmp = line.split("[^A-Za-z_0-9.]");

        context = tmp[tmp.length - 1];
        int i = context.lastIndexOf('.');
        
        if (context.endsWith("."))
            filter = "";
        else if (i == -1) {
            filter = context;
            context = "";
        } else {
            filter = context.substring(i+1, context.length());
            context = context.substring(0, i);
        }
        
        return new Pair<String, String>(context, filter);

    } catch (BadLocationException e) {
        e.printStackTrace();
        return null;
    }   
   
}


/**
 * Looks up completions for name leading caret. If context is qualified,
 * list lookup that class in the context of the enclosing class, o.w. list
 * members of enclosing class.
 *  
 * @param d document
 * @param offset caret offset
 * @return completion proposals 
 */
public ICompletionProposal[] suggestedDecls(IDocument d, int offset) {

    String qualifedPart, filter; // context for completion
    {
        Pair<String, String> p = getContext(d, offset);
        qualifedPart = p.fst();
        filter = p.snd();
    }

    InstNode decl; // declaration to look up completions in
    {
        Maybe<InstClassDecl> enclosingClass = 
            new Lookup(fRoot).instClassAt(d, offset);
        
        if (enclosingClass.isNull())
            return null;

        // if no qualified part, use enclosing class, o.w. look up 
        // the qualified name leading caret
        
        Maybe<InstNode> mDecl = qualifedPart.equals("") 
            ? new Maybe<InstNode>(enclosingClass.value())
            : new Lookup(fRoot).lookupQualifiedName(
                    enclosingClass.value(), 
                    CompletionUtil.createDotAccess(qualifedPart.split("\\.")));
        
        if (mDecl.isNull()) // lookup of qualified name failed  
            return null;
        
        decl = mDecl.value();
    }
    
    return makeCompletions(
            decl.completionProposals(new CompletionFilter(filter)),
            filter,
            offset);
}

public ICompletionProposal[] computeCompletionProposals(ITextViewer viewer,
        int offset) {
    return suggestedDecls(viewer.getDocument(), offset);
}

/**
 *  Create completions from a list of InstNodes. 
 */
protected ICompletionProposal[] makeCompletions(
        List<InstNode> completions, 
        String filter, 
        int offset) {
    
    ICompletionProposal[] icps = new ICompletionProposal[completions.size()];
    
    for (int i = 0; i < icps.length; i++) {

        InstNode completion = completions.get(i);
        
        icps[i] = 
            new CompletionProposal(
                completion.name(),
                offset - filter.length(), 
                filter.length(), 
                completion.name().length(),
                completion.contentOutlineImage(),
                completion.name() + completion.proposalComment(),
                null,
                null);
    }
    
    Arrays.sort(icps, proposalComparator);
    
    return icps;
}

public IContextInformation[] computeContextInformation(ITextViewer viewer,
        int offset) {
    return null;
}

public char[] getCompletionProposalAutoActivationCharacters() {
    return new char[] { '.' };
}

public char[] getContextInformationAutoActivationCharacters() {
    return new char[] { '.' };
}

public IContextInformationValidator getContextInformationValidator() {
    return new ContextInformationValidator(this);
}

public String getErrorMessage() {
    return null;
}

public void updateAST(ASTNode<?> fRoot) {
    this.fRoot = fRoot;
    System.out.println(fRoot);
    fRoot.prettyPrint(System.out, "");
}


}
