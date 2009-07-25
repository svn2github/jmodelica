package org.jmodelica.ide.editor;

import org.eclipse.jface.text.IAutoEditStrategy;
import org.eclipse.jface.text.presentation.IPresentationReconciler;
import org.eclipse.jface.text.presentation.PresentationReconciler;
import org.eclipse.jface.text.reconciler.IReconciler;
import org.eclipse.jface.text.reconciler.MonoReconciler;
import org.eclipse.jface.text.rules.DefaultDamagerRepairer;
import org.eclipse.jface.text.rules.ITokenScanner;
import org.eclipse.jface.text.source.ISourceViewer;
import org.eclipse.jface.text.source.SourceViewerConfiguration;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.editor.editingstrategies.AnnotationParenthesisAdder;
import org.jmodelica.ide.editor.editingstrategies.BracketAdder;
import org.jmodelica.ide.editor.editingstrategies.CommentAdder;
import org.jmodelica.ide.editor.editingstrategies.EndOfBlockAdder;
import org.jmodelica.ide.editor.editingstrategies.ForIfAdder;
import org.jmodelica.ide.indent.IndentingAutoEditStrategy;
import org.jmodelica.ide.scanners.ModelicaCommentScanner;
import org.jmodelica.ide.scanners.ModelicaQIdentScanner;
import org.jmodelica.ide.scanners.ModelicaStringScanner;
import org.jmodelica.ide.scanners.generated.Modelica22AnnotationScanner;
import org.jmodelica.ide.scanners.generated.Modelica22DefinitionScanner;
import org.jmodelica.ide.scanners.generated.Modelica22NormalScanner;
import org.jmodelica.ide.scanners.generated.Modelica22PartitionScanner;



/**
 * Source viewer configuration which provides the projection viewer with a
 * presentation reconciler ...
 * 
 * @author emma
 * 
 */
public class ViewerConfiguration extends SourceViewerConfiguration {

Editor editor;

public ViewerConfiguration(Editor editor) {
    this.editor = editor;
}

@Override
public IAutoEditStrategy[] getAutoEditStrategies(
        ISourceViewer sourceViewer, String contentType) {
    return new IAutoEditStrategy[] { 
            AnnotationParenthesisAdder.adder,
            IndentingAutoEditStrategy.editStrategy,
            EndOfBlockAdder.adder,
            ForIfAdder.adder,
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
            new Modelica22NormalScanner(), 
            false,
            Modelica22PartitionScanner.NORMAL_PARTITION);
    addScanner(reconciler, 
            new Modelica22DefinitionScanner(), 
            false,
            Modelica22PartitionScanner.DEFINITION_PARTITION);
    addScanner(reconciler, 
            new ModelicaStringScanner(), 
            false,
            Modelica22PartitionScanner.STRING_PARTITION);
    addScanner(reconciler, 
            new ModelicaQIdentScanner(), 
            false,
            Modelica22PartitionScanner.QIDENT_PARTITION);
    addScanner(reconciler, 
            new ModelicaCommentScanner(), 
            false,
            Modelica22PartitionScanner.COMMENT_PARTITION);
    addScanner(reconciler, 
            new Modelica22AnnotationScanner(), 
            true,
            Modelica22PartitionScanner.ANNOTATION_PARTITION);
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
            editor.getStrategy(),
            false);
}

}
