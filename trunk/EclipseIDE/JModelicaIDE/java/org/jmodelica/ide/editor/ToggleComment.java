package org.jmodelica.ide.editor;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.text.TextSelection;
import org.jmodelica.ide.helpers.Util;


/**
 * Action for toggling c++-style comments on lines in selected region.
 * Duplicates functionality of java equivalent, but we can't depend on JDT.
 * @author philip
 */
public class ToggleComment extends Action {

protected Editor editor;

public ToggleComment(Editor editor) {
    super();
    setActionDefinitionId("JModelicaIDE.ModelicaToggleCommentCommand");
    this.editor = editor;
}

public boolean isComment(String line) {
    return line.trim().startsWith("//");
}

public String toggleComment(String line, boolean comment) {
    if (comment) {
        if (line.trim().startsWith("//"))
            return line.replaceFirst("//", "////");
        return "//" + line;
    } else {
        if (line.trim().startsWith("//"))
            return line.replaceFirst("//", "");
    }
    return line;
}

public void run() {

    IDocument d = editor.getDocument();
    if (d == null)
        return;

    ITextSelection sel =
            (ITextSelection) editor.getSelectionProvider().getSelection();

    String[] lines = new String[sel.getEndLine() - sel.getStartLine() + 1];
    try {
        for (int i = 0; i < lines.length; i++) {
            int lineStart = d.getLineOffset(sel.getStartLine() + i);
            int lineLength = d.getLineLength(sel.getStartLine() + i);
            lines[i] = d.get(lineStart, lineLength);
        }
    } catch (BadLocationException e) {
        e.printStackTrace();
        return;
    }

    // whether to toggle or untoggle comments in region depends on whether first
    // line is a comment
    boolean comment = !isComment(lines[0]);
    int offset_diff = 0;
    for (int i = 0; i < lines.length; i++) {
        String tmp = toggleComment(lines[i], comment);
        offset_diff += tmp.length() - lines[i].length();
        lines[i] = tmp;
    }
    try {
        // doing a single replace gives this action a single entry on the undo
        // stack
        int start = d.getLineOffset(sel.getStartLine());
        int length = d.getLineOffset(sel.getEndLine()) +
                     d.getLineLength(sel.getEndLine()) - 
                     start;
        d.replace(start, length, Util.implode("", lines));

        // keep selection the same
        editor.getSelectionProvider().setSelection(
                new TextSelection(start, length + offset_diff));
    } catch (BadLocationException e) {
        e.printStackTrace();
        return;
    }
}
}
