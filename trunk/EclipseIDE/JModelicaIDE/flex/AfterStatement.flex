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
package org.jmodelica.generated.scanners;

import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;

import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.helpers.BackwardsDocumentReader;
import org.jmodelica.ide.helpers.DocumentReader;
import org.jmodelica.ide.scanners.DocumentScanner;

%%

%public
%final
%class AfterStatementScanner
%extends DocumentScanner
%unicode
%buffer 256
%apiprivate
%int
%char
%table

%{
    public AfterStatementScanner() {
        this(new StringReader(""));
    }
    
    public boolean isAfterStatement(IDocument document, int offset) {
        reset(document, offset);
        try {
			return yylex() != 0;
		} catch (IOException e) {
			return true;
		}
    }
    
    protected void reset(Reader r) {
        yyreset(r);
    }
    
    protected DocumentReader createReader() {
        return new BackwardsDocumentReader();
    }
%}

Comment = ("/*" ~"*/") | ([^\n\r]* "//")
WhiteSpace = [ \t\n\r]+

%%

{WhiteSpace}	{ }
{Comment}		{ }
";"				{ return 1; }
.				{ return 0; }
<<EOF>>			{ return 1; }