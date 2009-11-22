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

import java.io.StringReader;
import java.io.Reader;
import org.jmodelica.ide.helpers.DocumentReader;
import org.jmodelica.ide.helpers.BackwardsDocumentReader;
import org.jmodelica.ide.scanners.BraceScanner;

%%

%public
%final
%class BackwardBraceScanner
%extends BraceScanner
%unicode
%buffer 256
%type Result
%char
%table

%{
    public BackwardBraceScanner() {
        this(new StringReader(""));
    }

    protected int getLength() {
    	return yychar + yylength();
    }

    protected int getOffset() {
    	return start - getLength() + 1;
    }
    
    protected void reset(Reader reader) {
        yyreset(reader);
    }

	protected DocumentReader createReader() {
        return new BackwardsDocumentReader();
    }
%}

String = "\"" ( [^\"\\] | . "\\" )* "\""
QIdent = "\'" ( [^\'\\] | . "\\" )* "\'"
Comment = ("/*" ~"*/") | ([^\n\r]* "//")
Other = [^{}()/\"\'\[\]]+
NotComment = "/" [^*/]

%%

"}"				{ addBrace(Brace.CURLY); }
"]"				{ addBrace(Brace.BRACK); }
")"				{ addBrace(Brace.PAREN); }
"{"				{ Result res = removeBrace(Brace.CURLY); if (res != Result.NONE) return res; }
"["				{ Result res = removeBrace(Brace.BRACK); if (res != Result.NONE) return res; }
"("				{ Result res = removeBrace(Brace.PAREN); if (res != Result.NONE) return res; }

{String}		{ }
{QIdent}		{ }
{Comment}		{ }
{Other}			{ }

{NotComment}	{ yypushback(1); }

<<EOF>>			{ return Result.EOF; }