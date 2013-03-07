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
