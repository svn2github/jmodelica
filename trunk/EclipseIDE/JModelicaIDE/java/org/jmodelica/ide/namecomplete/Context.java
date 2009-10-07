package org.jmodelica.ide.namecomplete;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;

public class Context {

final String qualifiedPart;
final CompletionFilter filter;

/**
 * Get context leading caret.
 * 
 * The context is determined by the text leading <code>caretOffset</code>. Two
 * values, context and filter are returned, where context represents a complete
 * qualified name, and filter represent a prefix.
 * 
 * E.g., leading text on the form 'a.b.prefix' results in
 * 
 * context = "a.b" 
 * filter = "prefix"
 * 
 * @param d document
 * @param caretOffset offset to lookup context at
 * @return a new Pair<String, String> containing context and filter.
 */
public Context(IDocument d, int caretOffset) {
    
    String qPart = "", fPart = "";

    try {

        int lineStart = d.getLineOffset(d.getLineOfOffset(caretOffset));

        String line = d.get(lineStart, caretOffset - lineStart);
        String[] tmp = line.split("[^_A-Za-z_0-9.]", -1);

        qPart = tmp[tmp.length - 1];
        int i = qPart.lastIndexOf('.');
        
        if (qPart.endsWith("."))
            fPart = "";
        else if (i == -1) {
            fPart = qPart;
            qPart = "";
        } else {
            fPart = qPart.substring(i+1, qPart.length());
            qPart = qPart.substring(0, i);
        }


    } catch (BadLocationException e) {
        e.printStackTrace();
    }   
   
    this.qualifiedPart = qPart;
    this.filter = new CompletionFilter(fPart);
}

public String qualifiedPart() { 
    return qualifiedPart;
}

public CompletionFilter filter() {
    return filter;
}

}
