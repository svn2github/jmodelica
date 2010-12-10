package org.jmodelica.ide.editor.editingstrategies;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IDocument;
import org.jmodelica.generated.scanners.Modelica32PartitionScanner;
import org.jmodelica.ide.helpers.Util;


/**
 * Auto edit strategy that inserts 'end $id;' when user has typed 'class '$id'.
 * 
 * @author philip
 * 
 */
public class EndOfBlockAdder extends EndStatementAdder {

public final static EndOfBlockAdder instance = new EndOfBlockAdder(); 

final static String[] openBlockKeywords = { "block", "class",
        "connector", "function", "model", "package", "record", "type" };

final static String NEWLINE = "(\r\n|\n|\r)\\s*"; 

final static String classRegex = 
    String.format(
        "(.|\r|\n)*(^|\\s)(%s)\\s+\\w+(\\ |\t)*",
        Util.implode("|", openBlockKeywords));

public void customizeDocumentCommand(
        IDocument doc,
        DocumentCommand c) 
{
    try {

        if (!c.text.matches(NEWLINE) ||
            Util.is(
                doc.getPartition(c.offset).getType())
            .notAmong(
                IDocument.DEFAULT_CONTENT_TYPE,
                Modelica32PartitionScanner.NORMAL_PARTITION)) 
        {
            return;
        }
        
        // assume looking back 100 chars will be sufficient
        String context; {
            int i = Math.max(0, c.offset - 100);
            context = doc.get(i, c.offset - i);
        }
        
        if (!context.matches(classRegex))
            return;
        
        super.addEndIfNotPresent(
            endStatementString(context),
            doc, 
            c.offset);

    } catch (BadLocationException e) {
        e.printStackTrace();
    }
}

public String endStatementString(String doc) {
    
    String[] words =
        doc.split("\\s+");
    return 
        String.format(
            "end %s;", 
            words[words.length - 1]);
}

}
