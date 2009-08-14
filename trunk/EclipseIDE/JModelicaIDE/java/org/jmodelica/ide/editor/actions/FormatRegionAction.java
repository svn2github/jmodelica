package org.jmodelica.ide.editor.actions;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ITextSelection;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.editor.Editor;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.ide.indent.AnchorList;
import org.jmodelica.ide.indent.IndentedSection;
import org.jmodelica.ide.scanners.generated.IndentationHintScanner;


/**
 * Action for auto indenting the selected region.
 * 
 * @author philip
 */
public class FormatRegionAction extends Action {

protected Editor editor;

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
    
    IDocument d = editor.getDocument();
    ITextSelection sel = editor.getSelection();

    IndentedSection sec = new IndentedSection(d.get());

    AnchorList<Integer> ancs = new IndentationHintScanner()
        .analyze(sec.toString())
        .bindEnv(d, IndentedSection.tabWidth);

    // replace all lines in document if nothing selected
    if (sel.getLength() == 0) {
        d.set(sec.indent(ancs).toString());
        return;
    }

    int begLine = sel.getStartLine();
    int endLine = sel.getEndLine();
    
    String section = sec.indent(ancs, begLine, endLine + 1)
                        .toString(begLine, endLine + 1);

    Util.replaceLines(d, begLine, endLine, section);

}
}
