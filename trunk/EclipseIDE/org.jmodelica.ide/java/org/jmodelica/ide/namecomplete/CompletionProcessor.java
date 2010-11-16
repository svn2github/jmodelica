package org.jmodelica.ide.namecomplete;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.jface.text.ITextViewer;
import org.eclipse.jface.text.contentassist.ContextInformationValidator;
import org.eclipse.jface.text.contentassist.ICompletionProposal;
import org.eclipse.jface.text.contentassist.IContentAssistProcessor;
import org.eclipse.jface.text.contentassist.IContextInformation;
import org.eclipse.jface.text.contentassist.IContextInformationValidator;
import org.jastadd.plugin.registry.ASTRegistry;
import org.jmodelica.ide.OffsetDocument;
import org.jmodelica.ide.compiler.ModelicaCompiler;
import org.jmodelica.ide.editor.EditorWithFile;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.modelica.compiler.InstNode;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;


/**
 * Completion processor for JModelica
 * 
 * @author philip
 * 
 */
public class CompletionProcessor implements IContentAssistProcessor {

public final static ModelicaCompiler compiler = 
    new ModelicaCompiler();

public final EditorWithFile editor;

public CompletionProcessor(EditorWithFile editor) {
    this.editor = editor;
}

/**
 * Looks up completions for identifier leading caret. If no identifier exists
 * (e.g. typically if completion was invoked on a new line), do lookup in
 * enclosing class.
 * 
 * @param doc document
 * @param offset caret offset
 * @return instance nodes of completion proposals
 */
public ArrayList<CompletionNode> suggestedDecls(
        OffsetDocument doc,
        Maybe<SourceRoot> root) {

    StoredDefinition def = 
        new Recompiler()
        .recompilePartial(
            doc,
            root,
            getFile());
    
    Context context = 
        new Context(doc);

    Maybe<InstNode> decl = 
        new Lookup(def)
        .lookupQualifiedName(
            context.qualified(), 
            doc);

    return decl.isNothing()
        ? new ArrayList<CompletionNode>() 
        : decl
          .value()
          .completionProposals(
              context.filter(),
              context.qualified().trim().length() == 0);
}

protected IFile getFile() {
    return editor.editorFile().iFile();
}

/**
 * Get the SourceRoot of project from ASTRegistry
 */
protected Maybe<SourceRoot> projectRoot() {

    ASTRegistry reg = 
        org.jastadd.plugin.Activator.getASTRegistry();
    
    if (getFile() == null)
        return Maybe.Nothing();
    
    return 
        new Maybe<SourceRoot>(
            (SourceRoot) 
            reg.lookupAST(
                null,
                getFile().getProject()));
}

/*
 * Overriding methods.
 */
public ICompletionProposal[] computeCompletionProposals(
        ITextViewer viewer,
        int offset) 
{

    OffsetDocument doc = 
        new OffsetDocument(
            viewer.getDocument(),
            offset);
    
    List<CompletionNode> proposals = 
        suggestedDecls(doc, projectRoot());

    int filterLength = 
        new Context(doc)
        .filter()
        .length();

    return 
        new CompletionProposalsArray(
            proposals, 
            filterLength, 
            offset)
        .toArray();
}

public IContextInformation[] computeContextInformation(
        ITextViewer viewer,
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
