package org.jmodelica.ide.indent;

import java.util.Arrays;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DefaultIndentLineAutoEditStrategy;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.TextUtilities;
import org.jmodelica.ide.helpers.IndentedSection;
import org.jmodelica.ide.scanners.generated.IndentationHintScanner;



/**
 * Auto editing strategy for indenting source code from indentation hints.
 * 
 * @author philip
 * 
 */
public class Indentor extends DefaultIndentLineAutoEditStrategy {

final static IndentationHintScanner ihs = new IndentationHintScanner();

protected int countTokens(IDocument d, int offset) throws BadLocationException {
    int lineStart = d.getLineInformationOfOffset(offset).getOffset();
    return IndentedSection.spacify(d.get(lineStart, offset - lineStart))
            .length();
}

/** Calculate indent at offset from hints. */
protected int getIndent(IDocument d, int begin, int end, boolean countSinks)
        throws BadLocationException {
    Anchor a = ihs.ancs.sinkAt(end + 1);
    if (!countSinks || a == null || a.offset < begin)
        a = ihs.ancs.anchorAt(begin + 1);

    return a.indent.modify(countTokens(d, a.reference),
            IndentedSection.tabWidth);
}


public void customizeDocumentCommand(IDocument d, DocumentCommand c) {
    try {
        boolean semicolon = c.text.equals(";");
        boolean hasNewlines = !Arrays.equals(TextUtilities.indexOf(d
                .getLegalLineDelimiters(), c.text, 0), new int[] { -1, -1 });
        boolean endsWithNewLine = TextUtilities.endsWith(d
                .getLegalLineDelimiters(), c.text) != -1;
        boolean pastedBlock = c.text.length() > 1;
        /* remove whitespace trailing cursor when breaking */
        if (!(semicolon || hasNewlines || pastedBlock))
            return;

        IRegion line = d.getLineInformationOfOffset(c.offset);
        int lineBegin = line.getOffset();
        int lineEnd = lineBegin + line.getLength();
        String text = d.get(0, lineEnd);
        ihs.analyze(text);

        /* Check if there are sinks on current line. In that case indent
           edited line */
        Anchor a = ihs.ancs.sinkAt(c.offset);
        if (a != Anchor.BOTTOM && a.offset >= lineBegin) {
            int sinkIndent = countTokens(d, a.reference);
            String tmp = new IndentedSection(d.get(lineBegin, c.offset - lineBegin))
                .offsetIndentTo(sinkIndent).toString();
            c.addCommand(lineBegin, c.offset - lineBegin, tmp, c.owner);
        }

        if (hasNewlines) {
            /* remove whitespace trailing cursor when breaking */
            c.length += findEndOfWhiteSpace(d, c.offset, lineEnd) - c.offset;

            int indent = getIndent(d, c.offset, lineEnd, false);

            if (pastedBlock)
                c.text = new IndentedSection(c.text).offsetIndentTo(indent)
                        .toString();

            int begText = findEndOfWhiteSpace(d, lineBegin, lineEnd);
            if (c.offset <= begText) {
                /* put 'cursor' in very beginning of line if breaking before
                   indent ends */
                c.length += c.offset - lineBegin;
                c.offset = lineBegin;
            } else
                 /* if breaking in the middle of line, remove indent from the
                    first row */
                c.text = IndentedSection.trimIndent(c.text);

            if (endsWithNewLine)
                c.text += IndentedSection.putIndent("", getIndent(d, c.offset,
                        lineEnd, true));
        }
        c.caretOffset = c.offset + c.length;
    } catch (Exception e) {
        System.out.println("Exception in indentation code");
        e.printStackTrace();
    }
}
}
