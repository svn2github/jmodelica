package org.jmodelica.ide.editor.editingstrategies;

import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.indent.DocUtil;


/**
 * Auto edit strategy that inserts *\/ if user types /*, then newline.
 * 
 * @author philip
 * 
 */
public class CommentAdder extends EndStatementAdder {

public final static CommentAdder adder = new CommentAdder();

public void customizeDocumentCommand(IDocument doc, DocumentCommand c) {
    
    String line = 
        new DocUtil(doc).getLinePartial(c.offset);

    boolean insertingNewline = 
        c.text.matches("(\n|\r)\\s*");
    boolean afterCommentStart = 
        line.matches("(.|\r|\n)*/\\*\\s*"); 
    
    if (!(insertingNewline && afterCommentStart)) 
        return;
    
    super.addEndIfNotPresent("*/", doc, c.offset);

}

}
