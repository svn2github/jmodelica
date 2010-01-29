package org.jmodelica.ide.namecomplete;

import org.eclipse.jface.text.BadLocationException;
import org.jmodelica.ide.OffsetDocument;

public class Context {

final String           qualifiedPart;
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
 * @param doc document
 * @param caretOffset offset to lookup context at
 * @return a new Pair<String, String> containing context and filter.
 */
public Context(OffsetDocument doc) {
    
    String qPart = "", 
           fPart = "";

    try {

        String context; {
            int lineStart =
                doc.getLineOffset(doc.getLineOfOffset(doc.offset));
            String[] tmp = 
                doc
                .get(lineStart, doc.offset - lineStart)
                .split("[^_A-Za-z_0-9.]", -1);
            context = 
                tmp[tmp.length - 1];
        }

        int i = 
            context.lastIndexOf('.');
        qPart = 
            context.substring(0, Math.max(0, i));
        fPart = 
            context.substring(i+1, context.length());

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
