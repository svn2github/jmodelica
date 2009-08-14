package org.jmodelica.ide.indent;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DefaultIndentLineAutoEditStrategy;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IDocument;
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

public final static IndentingAutoEditStrategy editStrategy = new IndentingAutoEditStrategy();

final static IndentationHintScanner ihs = new IndentationHintScanner();

/**
 * Count number of tokens in from lineStart of offset up until offset.   
 */
public static int countTokens(IDocument doc, int offset) {
    return IndentedSection.spacify(DocUtil.getLinePartial(doc, offset))
        .length();
}

/**
 * Calculate indent at offset from hints.
 * */
protected int getIndent(int begin, int end, 
        AnchorList<Integer> aList) {
    
    Anchor<Integer> a = aList.sinkAt(end + 1);
    
    if (a == null || a.offset < begin)
        a = aList.anchorAt(begin + 1);

    return a.indent;
}

public void customizeDocumentCommand(IDocument doc, DocumentCommand c) {

    try {
        boolean pastedBlock = c.text.length() > 1;
        boolean isSemicolon = c.text.equals(";");
        boolean isNewLine = TextUtilities.equals(doc.getLegalLineDelimiters(),
                c.text) != -1;
        boolean isTab = c.text.equals("\t");
    
        // breaking here not necessary for correctness, but we don't
        // want to analyse source code for every inserted character.
        if (!(isSemicolon || isNewLine || isTab || pastedBlock))
            return;
    
        int lineEnd = DocUtil.lineEndOffsetOfOffset(doc, c.offset);
        int lineBegin = DocUtil.lineStartOffsetOfOffset(doc, c.offset);
        
        AnchorList<Integer> anchors = 
            ihs.analyze(doc.get(0, lineEnd))
               .bindEnv(doc, IndentedSection.tabWidth);
        
        int indent = getIndent(c.offset, lineEnd, anchors);
    
        if (pastedBlock) {
    
            new PastedBlock(c.text).pasteInto(doc, c, indent);
    
        } else if (isNewLine) {
            /*
             * if inserting newline, indent new line to 'correct' indentation
             */
            c.text += IndentedSection.putIndent("", indent);
            c.length = findEndOfWhiteSpace(doc, c.offset, lineEnd) - c.offset;
    
        } else if (isTab) {
            /*
             * if insert tab before beginning of line, indent all the way to
             * 'correct' indentation
             */
            int textStart = DocUtil.textStart(doc, c.offset);
            
            if (c.offset < textStart ||
                c.offset == textStart && countTokens(doc, textStart) < indent)
            {
                c.offset = lineBegin;
                c.length = textStart - lineBegin;
                c.text = IndentedSection.putIndent("", indent);
            }
        }
    
        if (isSemicolon || isNewLine) {
    
            /*
             * Check if there are sinks on current line. In that case indent edited
             * line.
             */
    
            Anchor<Integer> a = anchors.sinkAt(c.offset);

            if (a == null || a.offset < lineBegin)
                return;

            int sinkIndent = countTokens(doc, a.reference);
            String line = 
                new IndentedSection(DocUtil.getLinePartial(doc, c.offset))
                    .offsetIndentTo(sinkIndent)
                    .toString();
            c.addCommand(lineBegin, c.offset - lineBegin, line, c.owner);
        }
    
        c.caretOffset = c.offset + c.length;
        
    } catch (BadLocationException e) { e.printStackTrace(); return; }
}
}