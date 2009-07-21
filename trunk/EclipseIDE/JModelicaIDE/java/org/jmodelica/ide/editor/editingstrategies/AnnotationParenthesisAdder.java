package org.jmodelica.ide.editor.editingstrategies;

import java.util.Arrays;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IAutoEditStrategy;
import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.scanners.generated.Modelica22PartitionScanner;


/**
 * Inserts closing parenthesis of annotation when user types opening
 * parenthesis. Closing parenthesis is added after cursor.
 */
public class AnnotationParenthesisAdder implements IAutoEditStrategy {


public void customizeDocumentCommand(IDocument d, DocumentCommand c) {

    if (c.text == null || !(c.text.equals(" ") || c.text.equals("(")))
        return;

    try {

        boolean inNormalPartition; {
            String regType = d.getPartition(c.offset).getType();
            inNormalPartition = 
                !regType.equals(Modelica22PartitionScanner.COMMENT_PARTITION) &&
                !regType.equals(Modelica22PartitionScanner.QIDENT_PARTITION); 
        }

        boolean atEndLine; {
            int line = d.getLineOfOffset(c.offset);
            int endLine = d.getLineOffset(line) + d.getLineLength(line);
            atEndLine = d.get(c.offset, endLine - c.offset).trim().isEmpty();
        }

        boolean afterAnnotation = d.get(0, c.offset).trim().
            endsWith("annotation");
        
        if (inNormalPartition && atEndLine && afterAnnotation) {
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
