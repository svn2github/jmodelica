package org.jmodelica.indent;

import java.util.Arrays;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DefaultIndentLineAutoEditStrategy;
import org.eclipse.jface.text.DocumentCommand;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.TextUtilities;
import org.jmodelica.ide.helpers.IndentedSection;
import org.jmodelica.ide.scanners.generated.IndentationHintScanner;
import org.jmodelica.ide.scanners.generated.IndentationHintScanner.Anchor;
import org.jmodelica.ide.scanners.generated.IndentationHintScanner.Sink;

/**
 * Auto editing strategy for indenting
 * @author philip
 *
 */
public class Indentor extends DefaultIndentLineAutoEditStrategy {

	final static IndentationHintScanner ihs = new IndentationHintScanner();
	
	protected int countTokens(IDocument d, int offset) 
		throws BadLocationException {
		int lineStart = d.getLineInformationOfOffset(offset).getOffset();
		return IndentedSection.spacify(
				d.get(lineStart, offset - lineStart)).length();
	}
	
	/** Calculate sink at offset */
	protected int getSink(IDocument d, DocumentCommand c, 
    					  int offset, int length) 
			throws BadLocationException {
		Sink sink = ihs.sinkAt(offset, offset + length);
		if (sink != null) 
			return countTokens(d, sink.reference.offset);
		return -1;
	}
	
	/** Add command to sink indentation at offset */
	protected void sinkRegion(IDocument d, DocumentCommand c, 
			                  int offset, int len)
			throws BadLocationException {
		int sink = getSink(d, c, offset, len);
		if (sink != -1) {
			String text = IndentedSection.putIndent(d.get(offset, len), sink);
			c.addCommand(offset, len, text, null);
		}
	}
	
	/** Calculate indent at offset */
	protected int getIndent(IDocument d, DocumentCommand c, 
							int offset, int len) 
			throws BadLocationException {
		int sink = getSink(d, c, offset, len);
		if (sink != -1) 
			return sink;
		Anchor a = ihs.anchorAt(offset);
		return a.indent.modify(countTokens(d, a.offset),
				IndentedSection.tabWidth);
	}

	public void customizeDocumentCommand(IDocument d, DocumentCommand c) {
		try {
			boolean semicolon = c.text.equals(";");
			boolean hasNewlines = !Arrays.equals(TextUtilities.indexOf(
					d.getLegalLineDelimiters(), c.text, 0), new int[] {-1,-1});
			boolean endsWithNewLine = TextUtilities.endsWith
					(d.getLegalLineDelimiters(), c.text) != -1;
			boolean pastedBlock = c.text.length() > 1;

			if (!(semicolon || hasNewlines || pastedBlock))
				return;
			
			IRegion line = d.getLineInformationOfOffset(c.offset);
			int lineEnd = line.getOffset() + line.getLength();
			ihs.analyze(d.get(0, line.getOffset() + line.getLength()));

			/* Add command to sink indent if needed */
			int len = c.offset - line.getOffset();
			int sink = getSink(d, c, line.getOffset(), len);
			if (sink != -1) {
				String text = IndentedSection.putIndent
					(d.get(line.getOffset(), len), sink);
				c.addCommand(line.getOffset(), len, text, null);
			}
			
			if (hasNewlines) {
				
				/* remove whitespace trailing cursor when breaking */
				c.length += findEndOfWhiteSpace(d, c.offset, lineEnd) - c.offset;

				int indent = getIndent(d, c, c.offset, 0);
				
				if (pastedBlock)
					c.text = new IndentedSection(c.text)
						.offsetIndentTo(indent).toString();
				
				int begText = findEndOfWhiteSpace(d, line.getOffset(), lineEnd);
				if (c.offset <= begText) {
					/* put 'cursor' in very beginning of line if 
					 * breaking before indent ends */
					c.length += c.offset - line.getOffset();
					c.offset = line.getOffset();
				} else
					/* if breaking in the middle of line, remove indent 
					 * from the first row */
					c.text = IndentedSection.trimIndent(c.text);

				if (endsWithNewLine) 
					c.text += IndentedSection.putIndent("", 
							getIndent(d, c, c.offset, lineEnd - c.offset));
			}
			c.caretOffset = c.offset + c.length;
		} catch (Exception e) {
			System.out.println("Exception in indentation code");
		} 
	}
	
}
