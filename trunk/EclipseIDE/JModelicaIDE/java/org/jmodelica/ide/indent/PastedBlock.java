package org.jmodelica.ide.indent;

import java.util.Arrays;

import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.TextUtilities;

public class PastedBlock {
    
    IndentedSection block;
    
    public PastedBlock(String text) {
        block = new IndentedSection(text);
    }
    
    public void pasteInto(
            IDocument doc, DocumentCommand c, int indent) {

        // adjust block to proper indent
        c.text = block.offsetIndentTo(indent).toString();
        
        int textStart 
            = new DocUtil(doc).textStart(c.offset);
        
        if (c.offset <= textStart) {
            // if pasting inside the indentation, trim whitespace around caret
            int lineBegin = 
                new DocUtil(doc).lineStartOffsetOfOffset(c.offset);
            c.length += c.offset - lineBegin;
            c.offset = lineBegin;
        } else {
            // if pasting in middle of the line, remove indent of first row of 
            // pasted section
            c.text = IndentedSection.trimIndent(c.text);
        }
        
        boolean containsNewlines = 
            !Arrays.equals(
                TextUtilities.indexOf(
                    doc.getLegalLineDelimiters(), c.text, 0), 
                    new int[] { -1, -1 } );
        boolean endsWithNewLine = 
            TextUtilities.endsWith(
                doc.getLegalLineDelimiters(), c.text) 
            != -1;

        if (containsNewlines && !endsWithNewLine) 
            // if pasted block contains newlines, but doesn't end in one
            // insert an extra newline at the end
            c.text = c.text + doc.getLegalLineDelimiters()[0];
        
    }
}
