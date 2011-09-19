package org.jmodelica.ide.editor.editingstrategies;

import java.util.Arrays;
import java.util.List;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IAutoEditStrategy;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.jmodelica.ide.actions.ToggleComment;
import org.jmodelica.ide.indent.DocUtil;
import org.jmodelica.ide.indent.IndentedSection;


public abstract class EndStatementAdder implements IAutoEditStrategy {

protected final static List<String> prefixes = Arrays.asList(
		"intitial", "equation", "algorithm",
        "public", "protected",
        "else", "elseif", "elsewhen");

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
                line.trim().split("\\s+", 2)[0]);
        
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
 * @param cmd
 */
public void addEndIfNotPresent(String end, IDocument doc, DocumentCommand cmd) {
	
	int offset = cmd.offset;

    if (endExists(end.trim(), doc, offset))
        return;
    
    String endStatement = 
        new IndentedSection(end).offsetIndentTo(
            IndentedSection.countIndent(
                new DocUtil(doc).getLinePartial(offset))) + 
        IndentedSection.lineSep;

    int endOffset;
    try {
    	endOffset = doc.getLineOffset(doc.getLineOfOffset(offset) + 1);
	} catch (BadLocationException e) {
		// We are at last line
		endOffset = doc.getLength();
		endStatement = IndentedSection.lineSep + endStatement;
	}
    try {
		cmd.addCommand(endOffset, 0, endStatement, null);
		cmd.doit = false;
	} catch (BadLocationException e) {
		// Can't add command, probably because we are right at end of doc
		// edit doc directly and accept that two undos are needed to undo edit
		try {
			doc.replace(offset, 0, endStatement);
		} catch (BadLocationException e1) {
		}
	}

}
}