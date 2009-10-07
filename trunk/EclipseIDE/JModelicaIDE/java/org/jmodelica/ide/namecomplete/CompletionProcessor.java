package org.jmodelica.ide.namecomplete;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ITextViewer;
import org.eclipse.jface.text.contentassist.ContextInformationValidator;
import org.eclipse.jface.text.contentassist.ICompletionProposal;
import org.eclipse.jface.text.contentassist.IContentAssistProcessor;
import org.eclipse.jface.text.contentassist.IContextInformation;
import org.eclipse.jface.text.contentassist.IContextInformationValidator;
import org.jastadd.plugin.registry.ASTRegistry;
import org.jmodelica.ide.ModelicaCompiler;
import org.jmodelica.ide.editor.Editor;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.InstNode;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;
import org.jmodelica.modelica.parser.ModelicaParser;

/**
 * Completion processor for JModelica
 * 
 * @author philip
 *
 */
public class CompletionProcessor implements IContentAssistProcessor {


public final static ModelicaCompiler compiler = new ModelicaCompiler(
        Maybe.Just(new ModelicaParser.CollectingReport()));

public final Editor editor;

public CompletionProcessor(Editor editor) {
    this.editor = editor;
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
    
    Context context = new Context(d, offset);
    
    StoredDefinition def =
        new Recompiler().recompilePartial(d, projectRoot(), offset);
    Maybe<InstNode> decl = 
        lookupQualifedPart(d, offset, context.qualifiedPart(), def);
    
    return decl.isNothing() 
            ? new ArrayList<CompletionNode>() 
            : decl.value().completionProposals(
                    context.filter(), 
                    context.qualifiedPart().equals(""));
}


/**
 *  Get the SourceRoot of project from ASTRegistry 
 */
private SourceRoot projectRoot() {

    ASTRegistry reg = org.jastadd.plugin.Activator.getASTRegistry();
    
    return (SourceRoot) reg.lookupAST(
            null, 
            editor.editorFile().iFile().getProject());
}


/**
 * Performs a lookup of the qualified part of the string completed on. If the
 * qualified part is empty, lookup should be done in class at caret, so
 * enclosing class is returned.
 */
private Maybe<InstNode> lookupQualifedPart(IDocument d, int offset,
        String qualifedPart, StoredDefinition def) {
    
    Lookup lookup = new Lookup(def);
    
    Maybe<InstClassDecl> mEnclosingClass = 
        lookup.instEnclosingClassAt(d, offset);
        
    return qualifedPart.equals("")
        ? new Maybe<InstNode>(mEnclosingClass.value()) 
        : lookup.lookupQualifiedName(qualifedPart, mEnclosingClass.value());
}

/*
 * Overriding methods.
 */
public ICompletionProposal[] computeCompletionProposals(ITextViewer viewer,
        int offset) {

    List<CompletionNode> proposals = 
        suggestedDecls(viewer.getDocument(), offset);
 
    int filterLength = 
        new Context(viewer.getDocument(), offset).filter().filter.length();
    
    return new CompletionProposalsArray(proposals, filterLength, offset).toArray();
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
