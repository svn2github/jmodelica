package org.jmodelica.ide.editor.actions;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ITextSelection;
import org.jmodelica.generated.scanners.IndentationHintScanner;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.editor.Editor;
import org.jmodelica.ide.indent.AnchorList;
import org.jmodelica.ide.indent.DocUtil;
import org.jmodelica.ide.indent.IndentedSection;


/**
 * Action for auto indenting the selected region.
 * 
 * @author philip
 */
public class FormatRegionAction extends Action {

protected final Editor editor;

public FormatRegionAction(Editor editor) {
    super();
    super.setId(IDEConstants.ACTION_FORMAT_REGION_ID);
    setActionDefinitionId(
            "JModelicaIDE.ModelicaFormatRegionCommand");
    this.editor = editor;
}

@Override
public void run() {

    //TODO: make formatting keep the same selection as before formatting 
    
    IDocument doc = editor.document();
    ITextSelection sel = editor.selection();

    IndentedSection sec = new IndentedSection(doc.get());

    AnchorList<Integer> ancs = new IndentationHintScanner()
        .analyze(sec.toString())
        .bindEnv(doc, IndentedSection.tabWidth);

    // replace all lines in document if nothing selected
    if (sel.getLength() == 0) {
        doc.set(sec.indent(ancs).toString());
        return;
    }

    int begLine = 
        sel.getStartLine();
    int endLine = 
        sel.getEndLine();
    
    String section = 
        sec
        .indent(ancs, begLine, endLine + 1)
        .toString(begLine, endLine + 1);

    new DocUtil(doc).replaceLines(begLine, endLine, section);

}
}
