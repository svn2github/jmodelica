package org.jmodelica.ide.indent;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;


public class DocUtil {

public static int textStart(IDocument doc, int offset) {
    try {
        int lo = doc.getLineInformationOfOffset(offset).getOffset();
        while (lo < doc.getLength()) {
            char c = doc.getChar(offset);
            if (c != ' ' && c != '\t')
                break;
            offset++;
        }
        return offset;
    } catch (BadLocationException e) {
        return 0;
    }
}

public static int lineStartOffsetOfOffset(IDocument doc, int offset) {
    try {
        return doc.getLineInformationOfOffset(offset).getOffset();
    } catch (BadLocationException e) {
        e.printStackTrace();
        return 0;
    }
}

public static int lineEndOffsetOfOffset(IDocument doc, int offset) {
    try {
        return lineStartOffsetOfOffset(doc, offset)
                + doc.getLineInformationOfOffset(offset).getLength();
    } catch (BadLocationException e) {
        e.printStackTrace();
        return 0;
    }
}

public static String getLinePartial(IDocument doc, int offset) {
    int lineStart = lineStartOffsetOfOffset(doc, offset);
    try {
        return doc.get(lineStart, offset - lineStart);
    } catch (BadLocationException e) {
        return "";
    }
}

}
