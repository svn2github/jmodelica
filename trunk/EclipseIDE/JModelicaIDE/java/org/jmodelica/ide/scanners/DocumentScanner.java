package org.jmodelica.ide.scanners;

import java.io.Reader;

import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.helpers.DocumentReader;

public abstract class DocumentScanner {
	protected DocumentReader reader;
	
	public DocumentScanner() {
		reader = createReader();
	}
	
	protected abstract void reset(Reader r);
	
	protected DocumentReader createReader() {
		return new DocumentReader();
	}
	
	public void reset(IDocument document, int offset) {
		reader.reset(document, offset);
		reset(reader);
	}
	
	public void reset(IDocument document, int offset, int length) {
		reader.reset(document, offset, length);
		reset(reader);
	}
}
