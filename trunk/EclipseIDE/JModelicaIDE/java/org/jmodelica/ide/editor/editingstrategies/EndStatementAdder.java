package org.jmodelica.ide.editor.editingstrategies;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IAutoEditStrategy;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.jmodelica.ide.indent.IndentedSection;


public abstract class EndStatementAdder implements IAutoEditStrategy {

protected String getLine(IDocument d, int line) throws BadLocationException {
    IRegion lineReg = d.getLineInformation(line);
    return d.get(lineReg.getOffset(), lineReg.getLength());
}

protected boolean doAdd(String endStmnt, IDocument d, int offset)
        throws BadLocationException {
    
    int line = d.getLineOfOffset(offset);
    int indent = IndentedSection.countIndent(getLine(d, line));
    
    if (getLine(d, line).contains(endStmnt))
        return false;

    for (line = line + 1; line < d.getNumberOfLines() - 1; line++) {

        if (IndentedSection.countIndent(getLine(d, line)) <= indent)
            break;

        if (getLine(d, line).contains(endStmnt))
            return false;
    }

    return !getLine(d, line).contains(endStmnt);
}


/**
 * Scans document and adds "end id;" if it can't find an end statement already, 
 * within the current scope. 
 * @param id 
 * @param d
 * @param offset
 */
public void tryAdd(String id, IDocument d, int offset) {

    try {

        if (!doAdd(id, d, offset))
            return;
        
        IRegion lineReg = d.getLineInformationOfOffset(offset);
        int lineEndOffset = lineReg.getOffset() + lineReg.getLength();

        String endStatement;
        {
            int line = lineReg.getOffset();
            String indent = IndentedSection.putIndent("", IndentedSection
                    .countIndent(d.get(line, offset - line)));
            endStatement = String.format("\n%s%s", indent, id);
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