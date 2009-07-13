package org.jmodelica.ide.editor;

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
public class CommentAdder implements IAutoEditStrategy {

public void customizeDocumentCommand(IDocument d, DocumentCommand c) {
    try {
        int lineStart = d.getLineInformationOfOffset(c.offset).getOffset();
        if (c.text.matches("(\n|\r)\\s*")
                && d.get(lineStart, c.offset - lineStart).matches(
                        "(.|\r|\n)*/\\*\\s*")) {
            String indent = IndentedSection.putIndent("", IndentedSection
                    .countIndent(d.get(lineStart, c.offset - lineStart)));
            c.length = 0;
            IRegion reg = d.getLineInformationOfOffset(c.offset);
            d.replace(reg.getOffset() + reg.getLength(), 0, String.format(
                    "\n%s*/", indent));
        }
    } catch (BadLocationException e) {
        e.printStackTrace();
    }

}

}
