package org.jmodelica.ide.editor.editingstrategies;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IAutoEditStrategy;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.ITypedRegion;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.ide.indent.IndentedSection;
import org.jmodelica.ide.scanners.generated.Modelica22PartitionScanner;


/**
 * Auto edit strategy that inserts 'end $id;' when user has typed 'class '$id'.
 * 
 * @author philip
 * 
 */
public class EndOfBlockAdder extends EndStatementAdder {

final static String[] openBlockKeywords = { "block", "when", "class",
        "connector", "function", "model", "package", "record", "type" };

final static String classRegex = String.format(
        
        "(.|\r|\n)*(^|\\s)(%s)\\s+\\w+(\\ |\t)*",
        
        Util.implode("|", openBlockKeywords));


public void customizeDocumentCommand(IDocument d, DocumentCommand c) {
    try {

        boolean inNormalPartition; {
            String regType = d.getPartition(c.offset).getType();
            inNormalPartition = 
                !regType.equals(Modelica22PartitionScanner.COMMENT_PARTITION) &&
                !regType.equals(Modelica22PartitionScanner.STRING_PARTITION) &&
                !regType.equals(Modelica22PartitionScanner.QIDENT_PARTITION); 
        }

        if (!inNormalPartition)
            return;
     
        String doc; {
            //for efficiency, assume class name + identifier <= 100 characters
            int start = Math.max(0, c.offset - 100);
            doc = d.get(start, c.offset - start);
        }

        if (c.text.matches("(\n|\r)\\s*") && doc.matches(classRegex)) {

            while (c.offset > 0 && 
                   IndentedSection.isIndentChar(d.getChar(c.offset - 1))) {
                c.offset--; 
                c.length++;
            }
           
            String blockId;{
                String[] words = doc.split("\\s+"); 
                blockId = words[words.length - 1];
            }
          
            tryAdd(String.format("end %s;", blockId), d, c.offset); 

        }
    } catch (BadLocationException e) {
        e.printStackTrace();
    }
}
}
