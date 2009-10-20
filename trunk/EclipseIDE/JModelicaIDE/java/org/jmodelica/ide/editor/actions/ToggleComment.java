package org.jmodelica.ide.editor.actions;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.text.TextSelection;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.editor.Editor;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.ide.indent.DocUtil;
import org.jmodelica.ide.indent.IndentedSection;


/**
 * Action for toggling c++-style comments on lines in selected region.
 * Duplicates functionality of java equivalent, but we can't depend on JDT.
 * 
 * @author philip
 */
public class ToggleComment extends Action {

protected final Editor editor;

public ToggleComment(Editor editor) {
    super();
    super.setId(IDEConstants.ACTION_TOGGLE_COMMENT_ID);
    super.setActionDefinitionId(
        "JModelicaIDE.ModelicaToggleCommentCommand");
    
    this.editor = editor;
}

public void run() {

    IDocument doc = 
        editor.document();
    ITextSelection sel = 
        editor.selection();

    String[] lines; {
        int nbrLines = sel.getEndLine() - sel.getStartLine() + 1;
        lines = new String[nbrLines];
    }
    
    for (int i = 0; i < lines.length; i++) 
        lines[i] = 
            new DocUtil(doc).
            getLineNumbered(sel.getStartLine() + i);

    // comment if some selected line uncommented
    boolean doComment = !isCommented(lines[0]);
    for (int i = 0; i < lines.length; i++) 
        lines[i] = toggleComment(lines[i], doComment);    
    
    String subs = 
        Util.implode(IndentedSection.lineSep, lines) 
        + IndentedSection.lineSep; 
    
    int diff =
        new DocUtil(doc)
        .replaceLines(
            sel.getStartLine(), 
            sel.getEndLine(), 
            subs);

    // set selection to keep selection 
    editor.getSelectionProvider().setSelection(
        new TextSelection(
            sel.getOffset(), 
            sel.getLength() + diff));
}

public static boolean isCommented(String line) {
    return line.trim().startsWith("//");
}

public String comment(String line) {
    if (isCommented(line))
        return line.replaceFirst("//", "////");
    return "//" + line;
}

public String uncomment(String line) {
    if (isCommented(line))
        return line.replaceFirst("//", "");
    return line;
}

public String toggleComment(String line, boolean doComment) {
    return 
        doComment 
            ? comment(line) 
            : uncomment(line);
}

}
