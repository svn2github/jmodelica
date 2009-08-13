package org.jmodelica.ide.indent;

import java.util.Arrays;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DefaultIndentLineAutoEditStrategy;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.TextUtilities;
import org.jmodelica.ide.scanners.generated.IndentationHintScanner;


/**
 * Auto editing strategy for indenting source code from indentation hints.
 * 
 * @author philip
 * 
 */
public class IndentingAutoEditStrategy extends
        DefaultIndentLineAutoEditStrategy {

public final static IndentingAutoEditStrategy editStrategy = 
    new IndentingAutoEditStrategy();

final static IndentationHintScanner ihs = new IndentationHintScanner();

public static int countTokens(IDocument d, int offset) {
    int lineStart;
    try {
        lineStart = d.getLineInformationOfOffset(offset).getOffset();
        return IndentedSection.spacify(
                d.get(lineStart, offset - lineStart)).length();
    } catch (BadLocationException e) {
        e.printStackTrace();
        return 0;
    }
}
/** Calculate indent at offset from hints. */
protected int getIndent(int begin, int end, boolean countSinks,
        AnchorList<Integer> aList) {
    
    Anchor<Integer> a = aList.sinkAt(end + 1);
    
    if (!countSinks || a == null || a.offset < begin)
        a = aList.anchorAt(begin + 1);

    return a.indent;
}

public void customizeDocumentCommand(IDocument d, DocumentCommand c) {
    try {
        boolean semicolon = c.text.equals(";");
        boolean hasNewlines = !Arrays.equals(TextUtilities.indexOf(d
                .getLegalLineDelimiters(), c.text, 0), new int[] { -1, -1 });
        boolean endsWithNewLine = TextUtilities.endsWith(d
                .getLegalLineDelimiters(), c.text) != -1;
        boolean pastedBlock = c.text.length() > 1;
        boolean isTab = c.text.equals("\t");
        
        /* remove whitespace trailing cursor when breaking */
        if (!(semicolon || hasNewlines || isTab))
            return;

        IRegion line = d.getLineInformationOfOffset(c.offset);
        int lineBegin = line.getOffset();
        int lineEnd = lineBegin + line.getLength();
        String text = d.get(0, lineEnd);
        
        AnchorList<Integer> ancs = ihs.analyze(text)
                .bindEnv(d, IndentedSection.tabWidth);

        boolean atBeginningOfLine = c.offset < findEndOfWhiteSpace(
                d, lineBegin, c.offset); 
        
        System.out.println(atBeginningOfLine);
        /*
         * Check if there are sinks on current line. In that case indent edited
         * line
         */
        Anchor<Integer> a = ancs.sinkAt(c.offset);
        if (a != null && a.offset >= lineBegin) {
            int sinkIndent = countTokens(d, a.reference);
            String tmp = new IndentedSection(d.get(lineBegin, c.offset
                    - lineBegin)).offsetIndentTo(sinkIndent).toString();
            c.addCommand(lineBegin, c.offset - lineBegin, tmp, c.owner);
        }

        if (isTab) {
            /*
             * if tabbing before beginning of line, put indentation at correct
             * level
             */
            int indent = getIndent(c.offset, lineEnd, true, ancs);
            String ind = d.get(lineBegin, c.offset - lineBegin);
            if (ind.trim().equals("")
                    && IndentedSection.spacify(ind).length() < indent) {
                c.offset = lineBegin;
                c.length = findEndOfWhiteSpace(d, lineBegin, lineEnd)
                        - lineBegin;
                c.text = IndentedSection.putIndent("", indent);
            }
        } else if (hasNewlines || atBeginningOfLine) {
            /* remove whitespace trailing cursor when breaking */
            c.length += findEndOfWhiteSpace(d, c.offset, lineEnd) - c.offset;

            if (pastedBlock) {
                int indent = getIndent(c.offset, lineEnd, false, ancs);
                c.text = new IndentedSection(c.text).offsetIndentTo(indent)
                        .toString();
            }

            int begText = findEndOfWhiteSpace(d, lineBegin, lineEnd);
            if (c.offset <= begText) {
                /*
                 * put 'cursor' in very beginning of line if breaking before
                 * indent ends
                 */
                c.length += c.offset - lineBegin;
                c.offset = lineBegin;
            } else
                /*
                 * if breaking in the middle of line, remove indent from the
                 * first row
                 */
                c.text = IndentedSection.trimIndent(c.text);

            if (endsWithNewLine)
                c.text += IndentedSection.putIndent("", getIndent(c.offset,
                        lineEnd, true, ancs));
        }

        c.caretOffset = c.offset + c.length;
    } catch (Exception e) {
        System.out.println("Exception in indentation code");
        e.printStackTrace();
    }
}
}