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

private IDocument d;
private int i;
private int length;
private int offset;
protected IToken start, middle, end;
protected String startStr, endStr;

public StupidScanner(IToken start, IToken middle, IToken end, String startStr,
        String endStr) {
    super();
    this.start = start;
    this.middle = middle;
    this.end = end;
    this.startStr = startStr;
    this.endStr = endStr;
}

public int getTokenLength() {
    if (i == 1)
        return startStr.length();
    else if (i == 2)
        return length - startStr.length() - endStr.length();
    else
        return endStr.length();
}

public int getTokenOffset() {
    if (i == 1)
        return offset;
    else if (i == 2)
        return offset + startStr.length();
    else
        return offset + length - endStr.length();
}

public IToken nextToken() {

    IToken t;

    if (i == 0)
        t = start;
    else if (i == 1)
        t = middle;
    else if (i == 2) {
        t = middle;
        try {
            if (d.get(offset, length).endsWith(endStr)) {
                t = end;
            }
        } catch (BadLocationException e) {
        }
    } else
        t = Token.EOF;

    i++;

    return t;
}

public void setRange(IDocument document, int offset, int length) {
    this.offset = offset;
    this.length = length;
    i = 0;
    d = document;
}

@Override
protected void reset(Reader r) {
}

}
