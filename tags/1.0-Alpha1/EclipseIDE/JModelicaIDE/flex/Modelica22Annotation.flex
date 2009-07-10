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
%class Modelica22AnnotationScanner
%extends HilightScanner
%unicode
%buffer 2048
%function nextTokenInternal
%apiprivate
%type IToken
%char
%table

%{
    private int start;
    
    public Modelica22AnnotationScanner() {
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

ID = {NONDIGIT} ({DIGIT}|{NONDIGIT})* | {Q_IDENT}
NONDIGIT = [a-zA-Z_]
S_CHAR = [^\"\\]
Q_IDENT = "\'" ( {Q_CHAR} | {S_ESCAPE} ) ( {Q_CHAR} | {S_ESCAPE} )* "\'"
STRING = "\"" ({S_CHAR}|{S_ESCAPE})* "\""
Q_CHAR = [^\'\\]
S_ESCAPE = "\\\'" | "\\\"" | "\\?" | "\\\\" | "\\a" | "\\b" | "\\f" | "\\n" | "\\r" | "\\t" | "\\v"
DIGIT = [0-9]
UNSIGNED_INTEGER = {DIGIT} {DIGIT}*
UNSIGNED_NUMBER = {DIGIT} {DIGIT}* ( "." ( {UNSIGNED_INTEGER} )? )? ( (e|E) ( "+" | "-" )? {UNSIGNED_INTEGER} )? | {DIGIT}* ( "." ( {UNSIGNED_INTEGER} )? )?

LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]

WhiteSpace = ({LineTerminator} | [ \t\f])+

Keyword = "each" | "final" | "replaceable" | "redeclare" | "and" | "or" | "not" | 
          "true" | "false" | "if" | "then" | "else" | "elseif" | "end" | "for" | 
          "flow" | "discrete" | "parameter" | "constant" | "input" | "output"
          
Operator = "(" | ")" | "{" | "}" | "[" | "]" | ";" | ":" | "." | "," | "+" | "-" | "*" | 
           "/" | "=" | "^" | "<" | "<=" | ">" | ">=" | "==" | "<>"
Normal = {Operator} | {ID} | {UNSIGNED_NUMBER}

TraditionalComment = "/*" ([^*]* | "*" [^/])* "*/"
EndOfLineComment = "//" {InputCharacter}* {LineTerminator}?
Comment = {TraditionalComment} | {EndOfLineComment} 

%%

{Keyword}     { return ANNOTATION_KEYWORD; }
{WhiteSpace}  { return ANNOTATION_NORMAL; }
{Normal}      { return ANNOTATION_NORMAL; }
{STRING}      { return ANNOTATION_STRING; }
{Comment}     { return ANNOTATION_COMMENT; }
.             { return ANNOTATION_NORMAL; }
<<EOF>>       { return Token.EOF; }
