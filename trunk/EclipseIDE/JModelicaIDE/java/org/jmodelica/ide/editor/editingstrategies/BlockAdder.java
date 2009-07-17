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
public class BlockAdder implements IAutoEditStrategy {

final static String[] openBlockKeywords = { "block", "when", "class",
        "connector", "function", "model", "package", "record", "type" };

final static String classRegex = String.format(
        
        "(.|\r|\n)*(^|\\s)(%s)\\s+\\w+\\s*",
        
        Util.implode("|", openBlockKeywords));


public void customizeDocumentCommand(IDocument d, DocumentCommand c) {
    try {

        ITypedRegion r = d.getPartition(c.offset);
        if (r.getType() == Modelica22PartitionScanner.ANNOTATION_PARTITION ||
            r.getType() == Modelica22PartitionScanner.COMMENT_PARTITION)
        {
            return;
        }

        String doc; {
            //for efficiency, assume class name + identifier <= 100 characters
            int start = Math.max(0, c.offset - 100);
            doc = d.get(start, c.offset - start);
        }

        if (c.text.matches("(\n|\r)\\s*") && doc.matches(classRegex)) {

            while (c.offset > 0
                    && (d.getChar(c.offset - 1) == ' ' || 
                        d.getChar(c.offset - 1) == '\t')) 
            {
                c.offset--;
                c.length++;
            }

            String blockId; {
                int idStartOffset = Math.max(
                        doc.lastIndexOf(' ',  c.offset - 1), 
                        doc.lastIndexOf('\t', c.offset - 1));
                blockId = doc.substring(idStartOffset + 1).trim();
            }

            // check if doc contains corresponding end statement already. this
            // could be improved by counting opening of models with name id too,
            // but for now this is a good enough heuristic
            if (d.get(c.offset, d.getLength() - c.offset).contains(
                    String.format("end %s;", blockId)))
                return;

            String blockIndent; {
                int lineStart = d.getLineInformationOfOffset(c.offset)
                        .getOffset();
                blockIndent = IndentedSection.putIndent("", IndentedSection
                        .countIndent(d.get(lineStart, c.offset - lineStart)));
            }

            // must insert end statement with d.replace, as if using the
            // DocumentCommand, it seems impossible to posititon cursor in the
            // middle of the command.text. this causes this class to cause two 
            // undo entries. TODO: fix
            String end = String.format("\n%send %s;", blockIndent, blockId);
            IRegion line = d.getLineInformationOfOffset(c.offset);
            d.replace(line.getOffset() + line.getLength(), 0, end);
        }
    } catch (BadLocationException e) {
        e.printStackTrace();
    }
}
}
