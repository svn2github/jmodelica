package org.jmodelica.ide.scanners;

import java.io.Reader;

import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.rules.IToken;
import org.eclipse.jface.text.rules.Token;

public abstract class StupidScanner extends HilightScanner {

	private boolean eof;
	private int length;
	private int offset;

	public int getTokenLength() {
		return length;
	}

	public int getTokenOffset() {
		return offset;
	}

	public IToken nextToken() {
		if (eof) {
			return Token.EOF;
		} else {
			eof = true;
			return getToken();
		}
	}

	abstract protected IToken getToken();
	
	public void setRange(IDocument document, int offset, int length) {
		this.offset = offset;
		this.length = length;
		eof = false;
	}

	@Override
	protected void reset(Reader r) {
	}

}
