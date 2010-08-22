package org.jmodelica.ide.indent;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DefaultIndentLineAutoEditStrategy;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IDocument;
import org.jmodelica.generated.scanners.IndentationHintScanner;


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

final static IndentationHintScanner ihs = 
    new IndentationHintScanner();


public static int countTokens(IDocument doc, int offset) {
    return 
        IndentedSection
        .spacify(
            new DocUtil(doc).getLinePartial(offset))
        .length();
}

/**
 * Calculate indent at offset from hints.
 * */
protected int getIndent(
        int begin, 
        int end, 
        AnchorList<Integer> aList) 
{
    
    Anchor<Integer> a = aList.sinkAt(end + 1);
    
    if (a == null || a.offset < begin)
        a = aList.anchorAt(begin + 1);

    return a.indent;
}

public void customizeDocumentCommand(IDocument doc, DocumentCommand c) {

    try {
        
        boolean pastedBlock = c.text.length() > 1 && !c.text.equals("\r\n");
        boolean isSemicolon = c.text.equals(";");
        boolean isNewLine = c.text.matches("\r|\n|\r\n");
        boolean isTab = c.text.equals("\t");
    
        // breaking here not necessary for correctness, but we don't
        // want to analyse source code for every inserted character.
        if (!(isSemicolon || isNewLine || isTab || pastedBlock))
            return;
    
        DocUtil docUtil
            = new DocUtil(doc); 
        
        int lineEnd = 
            docUtil.lineEndOffsetOfOffset(c.offset);
        int lineBegin =
            docUtil.lineStartOffsetOfOffset(c.offset);
        
        AnchorList<Integer> anchors = 
            ihs.analyze(doc.get(0, lineEnd))
               .bindEnv(doc, IndentedSection.tabWidth);
        
        int indent = 
            getIndent(c.offset, lineEnd, anchors);
    
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
            int textStart =
                docUtil.textStart(c.offset);
            
            if (c.offset < textStart ||
                c.offset == textStart && 
                countTokens(doc, textStart) < indent)
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

            int sinkIndent = 
                countTokens(doc, a.reference);
            String line = 
                new IndentedSection(
                    docUtil.getLinePartial(c.offset))
                .offsetIndentTo(sinkIndent)
                .toString();
            c.addCommand(
                lineBegin, 
                c.offset - lineBegin,
                line, 
                c.owner);
        }
    
        c.caretOffset = c.offset + c.length;
        
    } catch (BadLocationException e) { e.printStackTrace(); return; }
}
}