/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package org.jmodelica.ide.helpers;

import java.io.IOException;
import java.io.Reader;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;

public class DocumentReader extends Reader {

	protected IDocument doc;
	protected int off;
	protected int len;
	protected int pos;
	
	public DocumentReader() {
		doc = null;
	}
	
	public DocumentReader(IDocument document) {
		this(document, 0, document.getLength());
	}
	
	public DocumentReader(IDocument document, int offset) {
		this(document, offset, document.getLength());
	}
	
	public DocumentReader(IDocument document, int offset, int length) {
		doc = document;
		setPart(offset, length);
	}

	public void reset(IDocument document, int offset) {
		reset(document, offset, document.getLength() - offset);
	}

	public void reset(IDocument document, int offset, int length) {
		doc = document;
		setPart(offset, length);
	}

	protected void setPart(int offset, int length) {
		off = offset;
		len = length;
		if (off + len > doc.getLength())
			len = doc.getLength() - off;
		pos = 0;
	}

	@Override
	public void close() throws IOException {
		doc = null;
	}

	@Override
	public int read(char[] cbuf, int offset, int length) throws IOException {
		if (pos >= len || doc == null)
			return -1;
		if (pos + length > len)
			length = len - pos;
		try {
			String part = readString(length);
			part.getChars(0, length, cbuf, offset);
			pos += length;
		} catch (BadLocationException e) {
			return -1;
		} catch (NullPointerException e) {
			return -1;
		}
		return length;
	}

	@Override
	public int read() throws IOException {
		try {
			return pos < len ? nextChar() : -1;
		} catch (BadLocationException e) {
			return -1;
		} catch (NullPointerException e) {
			return -1;
		}
	}

	protected String readString(int length) throws BadLocationException {
		return doc.get(off + pos, length);
	}

	protected char nextChar() throws BadLocationException {
		return doc.getChar(off + pos++);
	}

	@Override
	public boolean ready() throws IOException {
		return doc != null && pos < len;
	}

	@Override
	public void reset() throws IOException {
		pos = off;
	}

	@Override
	public long skip(long n) throws IOException {
		pos += n;
		return n;
	}
}
