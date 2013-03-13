package org.jmodelica.ide.editor.editingstrategies;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IAutoEditStrategy;
import org.eclipse.jface.text.IDocument;
import org.jmodelica.generated.scanners.Modelica32PartitionScanner;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.ide.indent.DocUtil;


/**
 * Inserts closing ");" of annotation when user types opening parenthesis.
 * Closing parenthesis is added after cursor.
 */

public class AnnotationParenthesisAdder implements IAutoEditStrategy {

public final static AnnotationParenthesisAdder instance = 
    new AnnotationParenthesisAdder();

public void customizeDocumentCommand(IDocument doc, DocumentCommand c) {
    
    if (c.text == null || !(c.text.equals(" ") || c.text.equals("(")))
        return;

    try {

        boolean inSourcePartition =
            Util
            .is(doc.getPartition(c.offset).getType())
            .among(
                IDocument.DEFAULT_CONTENT_TYPE,
                Modelica32PartitionScanner.ANNOTATION_PARTITION,
                Modelica32PartitionScanner.NORMAL_PARTITION);
        
        boolean atEndLine = 
            new DocUtil(doc)
            .getLine(c.offset)
            .trim()
            .equals("");

        boolean afterAnnotation = 
            doc
            .get(0, c.offset)
            .trim()
            .endsWith("annotation");

        if (inSourcePartition && atEndLine && afterAnnotation) {
            String suffix = 
                (c.text.endsWith("(") ? "" : "(") + ")";
            c.text += suffix;
            c.shiftsCaret = false;
            c.caretOffset = c.offset + suffix.length() - 1;
        }
        
    } catch (BadLocationException e) {
        e.printStackTrace();
    }
}

}
