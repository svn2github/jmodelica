package org.jmodelica.ide.editor.editingstrategies;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IAutoEditStrategy;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.ide.indent.IndentedSection;


/**
 * Auto edit strategy that inserts 'end $id;' when user has typed <class> '$id'.
 * 
 * @author philip
 * 
 */
public class BlockAdder implements IAutoEditStrategy {

final static String[] openBlockKeywords = { "block", "when", "class",
        "connector", "function", "model", "package", "record", "type" };
final static String classRegex = String.format(
        "(.|\r|\n)*(^|\\s)(%s)\\s+\\w+\\s*", Util.implode("|",
                openBlockKeywords));

public void customizeDocumentCommand(IDocument d, DocumentCommand c) {
    try {

        String doc = d.get(0, c.offset);

        if (c.text.matches("(\n|\r)\\s*") && doc.matches(classRegex)) {
            // below will fail for qidents with spaces. oh noes!
            String id = doc.substring(doc.trim().lastIndexOf(" ")).trim();

            // check if doc contains corresponding end statement already
            if (d.get(c.offset, d.getLength() - c.offset).matches(
                    "(.|\r|\n)*\\send\\s*" + id.trim() + "\\s*;(.|\r|\n)*"))
                return;

            // put same indent as open block on end
            String indent; {
                int lineStart = d.getLineInformationOfOffset(c.offset)
                        .getOffset();
                indent = IndentedSection.putIndent("", IndentedSection
                        .countIndent(d.get(lineStart, c.offset - lineStart)));
            }

            IRegion reg = d.getLineInformationOfOffset(c.offset);
            d.replace(reg.getOffset() + reg.getLength(), 0, String.format(
                    "\n%send %s;", indent, id));
        }
    } catch (BadLocationException e) {
        e.printStackTrace();
    }
}
}
