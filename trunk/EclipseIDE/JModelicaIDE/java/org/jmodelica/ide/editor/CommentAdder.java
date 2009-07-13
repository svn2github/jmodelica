package org.jmodelica.ide.editor;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IAutoEditStrategy;
import org.eclipse.jface.text.IDocument;


/**
 * Auto edit strategy that inserts *\/ if user types /*, then newline.
 * 
 * @author philip
 * 
 */
public class CommentAdder implements IAutoEditStrategy {

public void customizeDocumentCommand(IDocument d, DocumentCommand c) {
    try {
        if (c.text.matches("(\n|\r)\\s*")
                && d.get(Math.max(0, c.offset - 10), c.offset).matches(
                        "(.|\r|\n)*/\\*\\s*")) {
            c.length = 0;
            d.replace(c.offset, 0, " */");
        }
    } catch (BadLocationException e) {
        e.printStackTrace();
    }

}

}
