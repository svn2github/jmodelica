package org.jmodelica.ide.editor.editingstrategies;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;


/**
 * Adds end for/if; when user types for/if ...
 * 
 * @author philip
 * 
 */

public class ForIfAdder extends EndStatementAdder{

public final static ForIfAdder adder = new ForIfAdder();

protected static final String templateRegex = "\\s*(%s)(\\s.*)?";

public void customizeDocumentCommand(IDocument doc,
            DocumentCommand c) {
        
        if (!c.text.matches("(\n|\r)\\s*"))
            return;
        
        try {

            String line; {
                IRegion lineReg = doc.getLineInformationOfOffset(c.offset);
                line = doc.get(lineReg.getOffset(), lineReg.getLength());
            }
            
            for (String keyword : new String[] {"for", "if", "while", "when"})
                if (line.matches(String.format(templateRegex, keyword)))
                    addEndIfNotPresent(
                            String.format("end %s;", keyword), 
                            doc, 
                            c.offset);
                
        } catch (BadLocationException e) {
            e.printStackTrace();
        }
        
    }

}
