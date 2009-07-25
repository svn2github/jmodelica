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
                addEndIfNotPresent("end for;", d, c.offset);

            else if (line.matches(ifRegex)) 
                addEndIfNotPresent("end if;", d, c.offset);
            
        } catch (BadLocationException e) {
            e.printStackTrace();
        }
        
    }

}
