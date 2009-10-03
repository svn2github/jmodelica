package org.jmodelica.ide.namecomplete;

import java.util.ArrayList;
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
import org.jastadd.plugin.registry.ASTRegistry;
import org.jmodelica.ide.ModelicaCompiler;
import org.jmodelica.ide.editor.Editor;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.Access;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstNode;
import org.jmodelica.modelica.compiler.StoredDefinition;

/**
 * Completion processor for JModelica
 * 
 * @author philip
 *
 */
public class Completions implements IContentAssistProcessor {


public final static ModelicaCompiler compiler = new ModelicaCompiler();

public final Editor editor;

public Completions(Editor editor) {
    this.editor = editor;
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
        String[] tmp = line.split("[^_A-Za-z_0-9.]", -1);

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
 * Looks up completions for identifier leading caret. If no identifier exists
 * (e.g. typically if completion was invoked on a new line), do lookup in
 * enclosing class.
 * 
 * @param d document
 * @param offset caret offset
 * @return instance nodes of completion proposals
 */
public ArrayList<CompletionNode> suggestedDecls(IDocument d, int offset) {
    
    String qualifedPart, filter;
    {
        Pair<String, String> p = getContext(d, offset);
        qualifedPart = p.fst();
        filter = p.snd();
    }
    
    ASTNode<?> root = compiler.recompile(d, 
            editor.editorFile().iFile()).value();
    
    if (root.isError() || 
        ((StoredDefinition)root).getNumElement() == 0) {
    
        ASTRegistry reg = org.jastadd.plugin.Activator.getASTRegistry();
        root = (ASTNode<?>) 
            reg.lookupAST(null, editor.editorFile().iFile().getProject());
        
    }
    
    root.debugNN("");
    
    InstNode decl;
    {
        Maybe<InstClassDecl> enclosingClass = 
            new Lookup(root).instEnclosingClassAt(d, offset);
        
        if (enclosingClass.isNothing())
            return new ArrayList<CompletionNode>();

        if (qualifedPart.equals(""))
            // if no qualified part, do look up in enclosing class
            decl = enclosingClass.value();
        else {
            // o.w. look up the qualified name leading caret in
            // enclosing class, and use result for lookup
            Access a = CompletionUtil.createDotAccess(qualifedPart.split("\\.")); 
            Maybe<InstNode> mDecl = new Lookup(root).lookupQualifiedName(
                    enclosingClass.value(), 
                    a);
        
            if (mDecl.isNothing()) 
                return new ArrayList<CompletionNode>();
            
            decl = mDecl.value();
        }
    }
    
    return decl.completionProposals(
            new CompletionFilter(filter),
            qualifedPart.equals(""));
}

public ICompletionProposal[] computeCompletionProposals(ITextViewer viewer,
        int offset) {

    return makeCompletions(
            suggestedDecls(viewer.getDocument(), offset),
            getContext(viewer.getDocument(), offset).snd(),
            offset);
}

/**
 *  Create completions from a list of InstNodes. 
 */
protected ICompletionProposal[] makeCompletions(
        List<CompletionNode> completions, 
        String filter, 
        int offset) {
    
    ICompletionProposal[] icps = new ICompletionProposal[completions.size()];
    
    for (int i = 0; i < icps.length; i++) {

        CompletionNode completion = completions.get(i);
        
        icps[i] = 
            new CompletionProposal(
                completion.completionName(),
                offset - filter.length(), 
                filter.length(), 
                completion.completionName().length(),
                completion.completionImage(),
                completion.completionName() + completion.completionDoc(),
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

}
