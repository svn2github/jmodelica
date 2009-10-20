package org.jmodelica.ide.editor.editingstrategies;

import java.util.Arrays;
import java.util.List;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IAutoEditStrategy;
import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.editor.actions.ToggleComment;
import org.jmodelica.ide.indent.DocUtil;
import org.jmodelica.ide.indent.IndentedSection;


public abstract class EndStatementAdder implements IAutoEditStrategy {

protected static List<String> prefixes = 
    Arrays.asList(
        "intitial",
        "equation",
        "algorithm",
        "public",
        "protected");

/**
 * Checks if endStmnt occurs among the source code lines after
 * <code> offset </code>, within or at the end of the scope at
 * <code> offset </code> (scope heuristically determined by indentation).
 * 
 */
protected boolean endExists(
    String endStmnt, 
    IDocument doc, 
    int offset)
{
    
    DocUtil docUtil = 
        new DocUtil(doc);
    
    int startLine;
    try {
        startLine = doc.getLineOfOffset(offset);
    } catch (BadLocationException e) {
        e.printStackTrace();
        return false;
    }
    
    int startIndent = 
        IndentedSection.countIndent(
            docUtil.getLineNumbered(startLine));
    
    int i;    
    for (i = startLine; i < doc.getNumberOfLines() - 1; i++) {
        
        String line =
            docUtil.getLineNumbered(i);
        
        boolean ignoreLine = 
            line.trim().equals("") || 
            ToggleComment.isCommented(line) ||
            prefixes.contains(
                line.trim().split("\\s+")[0]);
        
        if (ignoreLine)
            continue;
        
        boolean endStatementAtLine = 
            line.contains(endStmnt);
        
        boolean leftScope = 
            i > startLine && 
            IndentedSection.countIndent(line) <= startIndent;
        
        if (endStatementAtLine || leftScope)  
            break;
    }
    
    return 
        docUtil
        .getLineNumbered(i)
        .contains(endStmnt);
}

/**
 * Scans document and adds endStmnt if it can't find it already, 
 * within the current scope. 
 * @param end 
 * @param doc
 * @param offset
 */
public void addEndIfNotPresent(String end, IDocument doc, int offset) {

    if (endExists(end.trim(), doc, offset))
        return;
    
    String endStatement = 
        IndentedSection.lineSep +
        new IndentedSection(end).offsetIndentTo(
            IndentedSection.countIndent(
                new DocUtil(doc).getLinePartial(offset)));

    /*
     * must insert end statement with a replace, as if using the DocumentCommand
     * class, it seems impossible to position cursor in the middle of the
     * command.text. this causes this class to create two undo entries. TODO:
     * fix if possible
     */
    new DocUtil(doc).insertLineAfter(offset, endStatement);

}
}