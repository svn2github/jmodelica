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
package org.jmodelica.ide.scanners;

import java.io.Reader;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.rules.IToken;
import org.eclipse.jface.text.rules.Token;

public abstract class StupidScanner extends HilightScanner {

	private boolean eof;
	private int length;
	private int offset;
	protected IToken token;

	public StupidScanner(IToken t) {
		token = t;
	}

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
			return token;
		}
	}

	public void setRange(IDocument document, int offset, int length) {
		this.offset = offset;
		this.length = length;
		eof = false;
	}

	protected void reset(Reader r) {}

}
