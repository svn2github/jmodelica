package org.jmodelica.ide.editor.editingstrategies;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IAutoEditStrategy;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.jmodelica.ide.editor.actions.ToggleComment;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.ide.indent.IndentedSection;


public abstract class EndStatementAdder implements IAutoEditStrategy {

/**
 * Checks if endStmnt occurs among the source code lines after
 * <code> offset </code>, within or at the end of the scope at
 * <code> offset </code> (scope heuristically determined by indentation).
 * 
 */
protected boolean endExists(String endStmnt, IDocument d, int offset)
        throws BadLocationException {
    
    int startLine = d.getLineOfOffset(offset);
    int indent = IndentedSection.countIndent(Util.getLine(d, startLine));
    
    for (int ln = startLine; ln < d.getNumberOfLines() - 1; ln++) {
        
        String line = Util.getLine(d, ln);
        // ignore empty lines and comments
        if (line.trim().equals("") || 
                ToggleComment.isCommented(line))
            continue;
        // break if encounter line with less or equal indentation
        if (ln > startLine && IndentedSection.countIndent(line) <= indent)
            break;

        if (line.contains(endStmnt))
            return true;
    }
    return Util.getLine(d, startLine).contains(endStmnt);
}


/**
 * Scans document and adds ednStmnt if it can't find it already, 
 * within the current scope. 
 * @param endStmnt 
 * @param d
 * @param offset
 */
public void addEndIfNotPresent(String endStmnt, IDocument d, int offset) {

    try {

        if (endExists(endStmnt, d, offset))
            return;
        
        IRegion lineReg = d.getLineInformationOfOffset(offset);
        int lineEndOffset = lineReg.getOffset() + lineReg.getLength();

        String endStatement; {
            int line = lineReg.getOffset();
            String indent = IndentedSection.putIndent("", IndentedSection
                    .countIndent(d.get(line, offset - line)));
            endStatement = String.format("\n%s%s", indent, endStmnt);
        }

        // must insert end statement with d.replace, as if using the
        // DocumentCommand, it seems impossible to posititon cursor in the
        // middle of the command.text. this causes this class to cause two
        // undo entries. TODO: fix if possible
        d.replace(lineEndOffset, 0, endStatement);

    } catch (BadLocationException e) {
        e.printStackTrace();
    }
}
}