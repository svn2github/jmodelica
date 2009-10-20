package org.jmodelica.ide.indent;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;

/**
 * Utility functions for handling documents.
 * @author philip
 *
 */
public class DocUtil {

private IDocument doc;

public DocUtil(IDocument doc) {
    this.doc = doc;
}

/**
 * Returns the offset of the first non-whitespace character of line containing
 * <code> offset </code>.
 */
public int textStart(int offset) {
    try {
        int lo = lineStartOffsetOfOffset(offset);
        while (lo < doc.getLength()) {
            char c = doc.getChar(offset);
            if (c != ' ' && c != '\t')
                break;
            offset++;
        }
        return offset;
    } catch (BadLocationException e) {
        e.printStackTrace();
        return 0;
    }
}

/**
 * Get offset of start of line containing <code> offset </code>.
 */
public int lineStartOffsetOfOffset(int offset) {
    try {
        return doc.getLineInformationOfOffset(offset).getOffset();
    } catch (BadLocationException e) {
        e.printStackTrace();
        return 0;
    }
}

/**
 * Get offset of end of line containing <code> offset </code>.
 */
public int lineEndOffsetOfOffset(int offset) {
    try {
        return lineStartOffsetOfOffset(offset)
                + doc.getLineInformationOfOffset(offset).getLength();
    } catch (BadLocationException e) {
        e.printStackTrace();
        return 0;
    }
}

/**
 * Get the segment from start of line, to offset, of the line containing
 * <code> offset </code>.
 */
public String getLinePartial(int offset) {
    int lineStart = lineStartOffsetOfOffset(offset);
    try {
        return doc.get(lineStart, offset - lineStart);
    } catch (BadLocationException e) {
        e.printStackTrace();
        return "";
    }
}

/**
 * Get the line containing offset.
 */
public String getLine(int offset) {
    try {
        int start = lineStartOffsetOfOffset(offset);
        int end = lineEndOffsetOfOffset(offset);
        return doc.get(start, end - start);
                       
    } catch (BadLocationException e) {
        e.printStackTrace();
        return "";
    } 
}

/**
 * Returns line with line number <code>lineNbr</code. Unlinke the getLine
 * method, this method includes the endLine token of that line.
 */
public String getLineNumbered(int lineNbr) {
    try {
        return getLine(doc.getLineOffset(lineNbr));
    } catch (BadLocationException e) {
        e.printStackTrace();
        return "";
    }
}

/**
 * Return line offset of of line numbered <code>lineNbr</code>
 */
public int getLineOffsetOfLine(int lineNbr) {
    try {
        return doc.getLineOffset(lineNbr);
    } catch (BadLocationException e) {
        e.printStackTrace();
        return 0;
    }
}

/**
 * Replaces the line containing <code> offset </code> with <code> subs </code>
 * in document.
 */
public IDocument replaceLineAt(
        int offset, 
        String subs) 
{
    
    try {
        int start = lineStartOffsetOfOffset(offset);
        int end = lineEndOffsetOfOffset(offset);
        doc.replace(start, end - start, subs);
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    return doc;
}

/**
 * Insert a line after the line containing <code>offset</code>.
 */
public IDocument insertLineAfter(
    int offset,
    String subs) 
{
    try {
        doc.replace(
            lineEndOffsetOfOffset(offset), 
            0, 
            subs);
        
    } catch (BadLocationException e) {
        e.printStackTrace();
    }
    
    return doc;
}

/**
 * Replaces lines between <code>begLine</code> and <code>endLine</code> with
 * <code>str</code>. Returns the diff in number of characters resulting from
 * replacement.
 * 
 * Note: This is used to replace several lines with one Document.replace. This
 * has the effect of a single Undo item being pushed in Eclipse. Thus this
 * method is not equivalent to several usages of replaceLineAt().
 */
public int replaceLines(int begLine, int endLine,
        String str) {

    try {
        int startOffset = doc.getLineOffset(begLine);
        int endOffset = endLine < doc.getNumberOfLines() - 1
            ? doc.getLineOffset(endLine + 1)
            : doc.getLength();
        int length = endOffset - startOffset;
        
        doc.replace(startOffset, length, str);
        
        return str.length() - length; 
        
    } catch (BadLocationException e) {
        e.printStackTrace();
        return 0;
    }
}

}
