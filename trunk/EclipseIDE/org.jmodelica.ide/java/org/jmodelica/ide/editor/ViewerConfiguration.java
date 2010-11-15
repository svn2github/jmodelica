package org.jmodelica.ide.editor;

import org.eclipse.jface.text.IAutoEditStrategy;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.contentassist.ContentAssistant;
import org.eclipse.jface.text.contentassist.IContentAssistant;
import org.eclipse.jface.text.presentation.IPresentationReconciler;
import org.eclipse.jface.text.presentation.PresentationReconciler;
import org.eclipse.jface.text.reconciler.IReconciler;
import org.eclipse.jface.text.reconciler.MonoReconciler;
import org.eclipse.jface.text.rules.DefaultDamagerRepairer;
import org.eclipse.jface.text.rules.ITokenScanner;
import org.eclipse.jface.text.source.ISourceViewer;
import org.eclipse.jface.text.source.SourceViewerConfiguration;
import org.jmodelica.generated.scanners.Modelica32AnnotationScanner;
import org.jmodelica.generated.scanners.Modelica32NormalScanner;
import org.jmodelica.generated.scanners.Modelica32PartitionScanner;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.editor.editingstrategies.AnnotationParenthesisAdder;
import org.jmodelica.ide.editor.editingstrategies.BracketAdder;
import org.jmodelica.ide.editor.editingstrategies.CommentAdder;
import org.jmodelica.ide.editor.editingstrategies.EndOfBlockAdder;
import org.jmodelica.ide.editor.editingstrategies.KeywordAdder;
import org.jmodelica.ide.indent.IndentingAutoEditStrategy;
import org.jmodelica.ide.namecomplete.CompletionProcessor;
import org.jmodelica.ide.scanners.ModelicaCommentScanner;
import org.jmodelica.ide.scanners.ModelicaQIdentScanner;
import org.jmodelica.ide.scanners.ModelicaStringScanner;


/**
 * Source viewer configuration which provides the projection viewer with a
 * presentation reconciler ...
 * 
 * @author emma
 * 
 */
public class ViewerConfiguration extends SourceViewerConfiguration {

final Editor editor;
final CompletionProcessor completions;

public ViewerConfiguration(Editor editor) {
    this.editor = editor;
    this.completions = editor.completions();
}

@Override
public IAutoEditStrategy[] getAutoEditStrategies(
        ISourceViewer sourceViewer, String contentType) {
    // note: order significant here
    return new IAutoEditStrategy[] { 
            // IndentingAutoEditStrategy is first, so no other command
            // makes it believe it's receiving a pasted block. 
            IndentingAutoEditStrategy.editStrategy,
            EndOfBlockAdder.adder,
            KeywordAdder.adder,
            // annotation paren adder before normal paren adder
            AnnotationParenthesisAdder.adder,
            new BracketAdder("(", ")"),
            new BracketAdder("[", "]"),
            new BracketAdder("{", "}"),
            new BracketAdder("\"", "\""),
            new BracketAdder("'", "'"),
            CommentAdder.adder,
        };
}

@Override
public String[] getDefaultPrefixes(ISourceViewer sourceViewer,
        String contentType) {
    return new String[] { "//" };
}

@Override
public String[] getConfiguredContentTypes(ISourceViewer sourceViewer) {
    return IDEConstants.CONFIGURED_CONTENT_TYPES;
}

// Override methods in the super class to get a specialised hover,
// content assist etc.
@Override
public IPresentationReconciler getPresentationReconciler(ISourceViewer sourceViewer) {
    // The scanner is set via the PresentationReconciler and a
    // DamageRepairer
    PresentationReconciler reconciler = new PresentationReconciler();
    addScanner(reconciler, 
            new Modelica32NormalScanner(), 
            false,
            Modelica32PartitionScanner.NORMAL_PARTITION);
    addScanner(reconciler, 
            new ModelicaStringScanner(), 
            false,
            Modelica32PartitionScanner.STRING_PARTITION);
    addScanner(reconciler, 
            new ModelicaQIdentScanner(), 
            false,
            Modelica32PartitionScanner.QIDENT_PARTITION);
    addScanner(reconciler, 
            new ModelicaCommentScanner(), 
            false,
            Modelica32PartitionScanner.COMMENT_PARTITION);
    addScanner(reconciler, 
            new Modelica32AnnotationScanner(), 
            true,
            Modelica32PartitionScanner.ANNOTATION_PARTITION);
  return reconciler;
}

private void addScanner(PresentationReconciler reconciler,
        ITokenScanner scanner, boolean doRestart, String type) {
    
    DefaultDamagerRepairer dr;
    dr = doRestart
        ? new RestartDamagerRepairer(scanner)
        : new DefaultDamagerRepairer(scanner);
    
    reconciler.setDamager(dr, type);
    reconciler.setRepairer(dr, type);
}

@Override 
public IReconciler getReconciler(ISourceViewer sourceViewer) {
    return new MonoReconciler(
            editor.strategy(),
            false);
}

@Override
public IContentAssistant getContentAssistant(ISourceViewer sourceViewer) {
    
    ContentAssistant assist = new ContentAssistant();
    
    assist.setContentAssistProcessor(completions, IDocument.DEFAULT_CONTENT_TYPE);
    assist.setContentAssistProcessor(completions, Modelica32PartitionScanner.NORMAL_PARTITION);
     
    return assist;
}

}
