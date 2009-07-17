package org.jmodelica.ide.editor;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ITextSelection;
import org.jmodelica.ide.indent.AnchorList;
import org.jmodelica.ide.indent.IndentedSection;
import org.jmodelica.ide.scanners.generated.IndentationHintScanner;


/**
 * Action for auto indenting the selected region.
 * @author philip
 */
public class FormatRegionAction extends Action {

protected Editor editor;

public FormatRegionAction(Editor editor) {
    super();
    setActionDefinitionId("JModelicaIDE.ModelicaFormatRegionCommand");
    this.editor = editor;
}

@Override
public void run() {

    IDocument d = editor.getDocument();
    if (d == null)
        return;

    ITextSelection sel =
            (ITextSelection) editor.getSelectionProvider().getSelection();
    
    String doc = d.get();
    IndentationHintScanner ihs = new IndentationHintScanner();
    ihs.analyze(doc);
    AnchorList<Integer> ancs = ihs.ancs.bindTabWidth(IndentedSection.tabWidth);

    if (sel.getLength() == 0) {
        d.set(new IndentedSection(doc).indent(ancs).toString());  
    } else {
        int beg = sel.getStartLine();
        int end = sel.getEndLine() + 1;
        String section = new IndentedSection(doc).indent(ancs, beg, end)
                .toString(beg, end);
        try {
            int startOffset = d.getLineOffset(beg);
            int endOffset = d.getLineOffset(end - 1);
            endOffset += d.getLineInformationOfOffset(endOffset).getLength();
            d.replace(startOffset, endOffset - startOffset, section);
        } catch (BadLocationException e) {
            e.printStackTrace();
        }
    }
}
}
