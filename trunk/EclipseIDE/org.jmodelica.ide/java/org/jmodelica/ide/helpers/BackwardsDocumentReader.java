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

	@Override
	protected String readString(int length) throws BadLocationException {
		return new StringBuilder(doc.get(off - pos - length + 1, length)).reverse().toString();
	}

}
