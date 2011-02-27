package org.jmodelica.ide.editor.editingstrategies;

import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.indent.DocUtil;


/**
 * Adds end for/if; when user types for/if ...
 * 
 * @author philip
 * 
 */

public class KeywordAdder extends EndStatementAdder{

public final static KeywordAdder instance = new KeywordAdder();

protected static final String[] KEYWORDS =
    {"for", "if", "while", "when"};
protected static final String TEMPLATE_REGEX = 
    "\\s*(%s)(\\s.*)?";

public void customizeDocumentCommand(IDocument doc,
            DocumentCommand c) {
        
        if (!c.text.matches("(\n|\r)\\s*"))
            return;
        
        String line = 
            new DocUtil(doc).getLinePartial(c.offset);
        
        for (String keyword : KEYWORDS) {
            if (line.matches(
                    String.format(TEMPLATE_REGEX, keyword))) 
            {
                addEndIfNotPresent(
                    String.format("end %s;", keyword), 
                    doc, 
                    c.offset);
            }
        }
    }

}
