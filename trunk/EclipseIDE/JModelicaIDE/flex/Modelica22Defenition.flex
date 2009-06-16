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

import java.io.Reader;
import java.io.StringReader;

import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.rules.IToken;
import org.eclipse.jface.text.rules.Token;

import org.jmodelica.ide.scanners.HilightScanner;

%%

%public
%final
%class Modelica22DefenitionScanner
%extends HilightScanner
%unicode
%buffer 128
%function nextTokenInternal
%apiprivate
%type IToken
%char
%table

%{
    private int start;
    
    public Modelica22DefenitionScanner() {
        this(new StringReader(""));
    }
    
    public IToken nextToken() {
        try {
            return nextTokenInternal();
        } catch (java.io.IOException e) {
            return Token.EOF;
        }
    }

    public int getTokenLength() {
    	return yylength();
    }

    public int getTokenOffset() {
    	return start + yychar;
    }

    public void setRange(IDocument document, int offset, int length) {
        start = offset;
    	reset(document, offset, length);	
    }
    
    protected void reset(Reader r) {
        yyreset(r);
    }
%}

NONDIGIT = [a-zA-Z_]
DIGIT = [0-9]

WhiteSpace = [ \t\f\n\r]+
NormalID = {NONDIGIT} ({DIGIT}|{NONDIGIT})*
Class = "block" | "class" | "connector" | "function" | "model" | "package" | "record" | "type"

%%

{Class}        { return KEYWORD; }
{NormalID}     { return DEFENITION; }
{WhiteSpace}   { return NORMAL; }
.              { return NORMAL; }
<<EOF>>        { return Token.EOF; }