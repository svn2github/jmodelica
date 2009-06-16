package org.jmodelica.ide.helpers;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;

public class BackwardsDocumentReader extends DocumentReader {
	
	public BackwardsDocumentReader() {
		doc = null;
	}

	public BackwardsDocumentReader(IDocument document) {
		super(document, document.getLength() - 1, document.getLength());
	}

	public BackwardsDocumentReader(IDocument document, int offset) {
		super(document, offset, offset + 1);
	}

	public BackwardsDocumentReader(IDocument document, int offset, int length) {
		super(document, offset, length);
	}

	@Override
	protected char nextChar() throws BadLocationException {
		return doc.getChar(off - pos++);
	}

	@Override
	public void reset(IDocument document, int offset) {
		reset(document, offset, offset + 1);
	}

	@Override
	protected void setPart(int offset, int length) {
		off = offset;
		len = length;
		if (off > doc.getLength() - 1)
			off = doc.getLength() - 1;
		if (off - len + 1 < 0)
			len = off + 1;
		pos = 0;
	}

}
