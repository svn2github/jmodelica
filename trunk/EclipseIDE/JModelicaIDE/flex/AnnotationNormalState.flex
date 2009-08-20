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

import java.io.Reader;
import java.io.StringReader;

import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.scanners.DocumentScanner;

%%

%public
%final
%class AnnotationNormalStateScanner
%extends DocumentScanner
%unicode
%buffer 1024
%int
%apiprivate
%char
%table

%{
    public AnnotationNormalStateScanner() {
        this(new StringReader(""));
    }
    
    public boolean isNormalState(IDocument doc, int start, int offset) {
        reset(doc, start, offset - start + 1);
        try {
            return yylex() != 0;
        } catch (java.io.IOException e) {
            return false;
        }
    }
    
    protected void reset(Reader r) {
        yyreset(r);
    }
%}

String = ( [^\"\\] | "\\" . )+
QIdent = ( [^\'\\] | "\\" . )+
Comment = ( [^*] | "*" [^/] )+
Other = [^/\"\']+
NotComment = "/" [^*/]

%state STRING, QIDENT, COMMENT, LINECOMMENT

%%

<YYINITIAL> {
  "\""				{ yybegin(STRING); }
  "\'"				{ yybegin(QIDENT); }
  "/*"				{ yybegin(COMMENT); }
  "//"				{ yybegin(LINECOMMENT); }
  {Other}			{ }
  <<EOF>>			{ return 1; }
  {NotComment}		{ yypushback(1); }
}

<STRING> {
  "\""				{ yybegin(YYINITIAL); }
  <<EOF>>			{ return 0; }
  {String}			{ }
}

<QIDENT> {
  "\'"				{ yybegin(YYINITIAL); }
  <<EOF>>			{ return 0; }
  {QIdent}			{ }
}

<COMMENT> {
  "*/"				{ yybegin(YYINITIAL); }
  <<EOF>>			{ return 0; }
  {Comment}			{ }
}

<LINECOMMENT> {
  (\n|\r|\n\r)		{ yybegin(YYINITIAL); }
  <<EOF>>			{ return 0; }
  [^\n\r]+			{ }
}