package org.jmodelica.ide.editor.editingstrategies;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IAutoEditStrategy;
import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.ide.scanners.generated.Modelica22PartitionScanner;


/**
 * Inserts closing ");" of annotation when user types opening parenthesis.
 * Closing parenthesis is added after cursor.
 */

public class AnnotationParenthesisAdder implements IAutoEditStrategy {

public final static AnnotationParenthesisAdder adder = 
    new AnnotationParenthesisAdder();

public void customizeDocumentCommand(IDocument d, DocumentCommand c) {

    if (c.text == null || !(c.text.equals(" ") || c.text.equals("(")))
        return;

    try {

        boolean inSourcePartition =
            Util.is(d.getPartition(c.offset).getType()).among(
                    IDocument.DEFAULT_CONTENT_TYPE,
                    Modelica22PartitionScanner.DEFINITION_PARTITION,
                    Modelica22PartitionScanner.NORMAL_PARTITION);
        
        boolean atEndLine; {
            int line = d.getLineOfOffset(c.offset);
            int endLine = d.getLineOffset(line) + d.getLineLength(line);
            atEndLine = d.get(c.offset, endLine - c.offset).trim().equals("");
        }

        boolean afterAnnotation = d.get(0, c.offset).trim().
            endsWith("annotation");
        
        if (inSourcePartition && atEndLine && afterAnnotation) {
            String suffix = "";
            if (!c.text.endsWith("("))
                suffix += "(";
            suffix += ");";
            
            c.text += suffix;
            c.shiftsCaret = false;
            c.caretOffset = c.offset + suffix.length() - 1;
        }
        
    } catch (BadLocationException e) {
        e.printStackTrace();
    }
}

}
