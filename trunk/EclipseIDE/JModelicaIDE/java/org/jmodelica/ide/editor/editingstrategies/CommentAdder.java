package org.jmodelica.ide.editor.editingstrategies;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IAutoEditStrategy;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.jmodelica.ide.indent.IndentedSection;


/**
 * Auto edit strategy that inserts *\/ if user types /*, then newline.
 * 
 * @author philip
 * 
 */
public class CommentAdder extends EndStatementAdder {

public void customizeDocumentCommand(IDocument d, DocumentCommand c) {
    try {

        int lineStart = d.getLineInformationOfOffset(c.offset).getOffset();
        String doc = d.get(lineStart, c.offset - lineStart);

        boolean insertingNewline = c.text.matches("(\n|\r)\\s*");
        boolean afterCommentStart = doc.matches("(.|\r|\n)*/\\*\\s*"); 
        
        if (!(insertingNewline && afterCommentStart)) 
            return;
        
        tryAdd("*/", d, c.offset);
        
    } catch (BadLocationException e) {
        e.printStackTrace();
    }

}

}
