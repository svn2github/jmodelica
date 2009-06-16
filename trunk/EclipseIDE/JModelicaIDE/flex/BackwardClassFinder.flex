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
package org.jmodelica.ide.scanners.generated;

import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;

import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.helpers.DocumentReader;
import org.jmodelica.ide.helpers.BackwardsDocumentReader;
import org.jmodelica.ide.scanners.DocumentScanner;

%%

%public
%final
%class BackwardClassFinder
%extends DocumentScanner
%unicode
%apiprivate
%buffer 1024
%int
%char
%table

%{
    private String target;
    private String last;
    private int level;
    private int tab;
    
    public BackwardClassFinder() {
        this(new StringReader(""));
    }
    
    public int findIndent(IDocument document, int offset, String id, int tab) {
        yyreset(new BackwardsDocumentReader(document, offset));
        if (id != null)
            this.target = new StringBuilder(id).reverse().toString();
        this.tab = tab;
        try {
			return yylex();
		} catch (IOException e) {
			return -1;
		}
    }
    
    private void foundClass() {
        if (target == null || target.equals(last)) {
            yybegin(INDENT);
            level = 0;
        }
    }
    
    protected DocumentReader createReader() {
        return new BackwardsDocumentReader();
    }
    
    protected void reset(Reader r) {
        yyreset(r);
    }
%}

NONDIGIT = [a-zA-Z_]
DIGIT = [0-9]
NormId = ({DIGIT}|{NONDIGIT})* {NONDIGIT}
QIdent = "\'" ( [^\'\\] | . "\\" )* "\'"
String = "\"" ( [^\"\\] | . "\\" )* "\""
Comment = ("/*" ~"*/") | ([^\n\r]* "//")
Id = {NormId} | {QIdent}
Class = "kcolb" | "ssalc" | "rotcennoc" | "noitcnuf" | "ledom" | "egakcap" | "drocer" | "epyt"

%state INDENT

%%

<YYINITIAL> {
  {Class}		{ foundClass(); }
  {Id}			{ last = yytext(); }

  {String}		{ }
  {Comment}		{ }
  
  .|\n			{ }

  <<EOF>>		{ return -1; }
}

<INDENT> {
  " "			{ level++; }
  "\t"			{ level += tab; }

  [\n\r]		{ return level; }
  <<EOF>>		{ return level; }
  
  .				{ level = 0; }
}