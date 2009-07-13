package org.jmodelica.ide.editor;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IAutoEditStrategy;
import org.eclipse.jface.text.IDocument;


/**
 * Auto edit strategy for adding brackets as user types. Mimics the way JDT
 * inserts ending parenthesis.
 * 
 * @author philip
 * 
 */
public class BracketAdder implements IAutoEditStrategy {

protected String startToken, endToken;

public BracketAdder(String startToken, String endToken) {
    this.startToken = startToken;
    this.endToken = endToken;
}

public void customizeDocumentCommand(IDocument d, DocumentCommand c) {
    try {
        int endLine; {
            int line = d.getLineOfOffset(c.offset);
            endLine = d.getLineOffset(line) + d.getLineLength(line);
        }
        if (c.text.equals(endToken)
                && c.offset <= d.getLength() - endToken.length()
                && d.get(c.offset, endToken.length()).equals(endToken)) {
            c.text = "";
            c.caretOffset = c.offset + 1;
        } else if (c.text.equals(startToken)
                && d.get(c.offset, endLine - c.offset).replaceAll("[^\\w]", "")
                        .isEmpty()) {
            c.text += endToken;
            c.shiftsCaret = false;
            c.caretOffset = c.offset + startToken.length();
        }
    } catch (BadLocationException e) {
        e.printStackTrace();
    }
}

}
