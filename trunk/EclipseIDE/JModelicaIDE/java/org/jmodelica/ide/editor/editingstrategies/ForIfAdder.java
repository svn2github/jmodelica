package org.jmodelica.ide.editor.editingstrategies;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;


/**
 * Adds end for; when user types for ...
 * 
 * @author philip
 * 
 */

public class ForIfAdder extends EndStatementAdder{

protected static final String forRegex = "\\s*for(\\s.*)?";
protected static final String ifRegex   = "\\s*if(\\s.*)?";

public void customizeDocumentCommand(IDocument d,
            DocumentCommand c) {
        
        if (!c.text.matches("(\n|\r)\\s*"))
            return;
        
        try {

            String line; {
                IRegion lineReg = d.getLineInformationOfOffset(c.offset);
                line = d.get(lineReg.getOffset(), lineReg.getLength());
            }
            
            if (line.matches(forRegex)) 
                tryAdd("end for;", d, c.offset);

            if (line.matches(ifRegex)) 
                tryAdd("end if;", d, c.offset);
            
        } catch (BadLocationException e) {
            e.printStackTrace();
        }
        
    }

}
