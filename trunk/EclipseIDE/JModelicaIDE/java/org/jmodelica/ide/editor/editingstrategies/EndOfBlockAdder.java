package org.jmodelica.ide.editor.editingstrategies;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IDocument;
import org.jmodelica.generated.scanners.Modelica22PartitionScanner;
import org.jmodelica.ide.helpers.Util;


/**
 * Auto edit strategy that inserts 'end $id;' when user has typed 'class '$id'.
 * 
 * @author philip
 * 
 */
public class EndOfBlockAdder extends EndStatementAdder {

public final static EndOfBlockAdder adder = new EndOfBlockAdder(); 

final static String[] openBlockKeywords = { "block", "class",
        "connector", "function", "model", "package", "record", "type" };

final static String classRegex = String.format(
        "(.|\r|\n)*(^|\\s)(%s)\\s+\\w+(\\ |\t)*",
        Util.implode("|", openBlockKeywords));

public void customizeDocumentCommand(IDocument d, DocumentCommand c) {
    try {

        boolean insertingNewline = c.text.matches("(\n|\r)\\s*");

        if (!insertingNewline)
            return;

        boolean inSourcePartition =
            Util.is(d.getPartition(c.offset).getType()).among(
                    IDocument.DEFAULT_CONTENT_TYPE,
                    Modelica22PartitionScanner.DEFINITION_PARTITION,
                    Modelica22PartitionScanner.NORMAL_PARTITION);
        
        if (!inSourcePartition)
            return;

        String doc;
        boolean afterClassBegin; {
            // for efficiency, assume class name + identifier <= 100 characters
            int start = Math.max(0, c.offset - 100);
            doc = d.get(start, c.offset - start);
            afterClassBegin = doc.matches(classRegex);
        }

        if (!afterClassBegin)
            return;

        String blockId; {
            String[] words = doc.split("\\s+");
            blockId = words[words.length - 1];
        }

        String endStatement = String.format("end %s;", blockId);
        super.addEndIfNotPresent(endStatement, d, c.offset);
                

    } catch (BadLocationException e) {
        e.printStackTrace();
    }
}
}
