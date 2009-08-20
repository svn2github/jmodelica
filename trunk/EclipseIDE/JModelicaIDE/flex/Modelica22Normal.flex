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
import org.eclipse.jface.text.rules.IToken;
import org.eclipse.jface.text.rules.Token;

import org.jmodelica.ide.scanners.HilightScanner;

%%

%public
%final
%class Modelica22NormalScanner
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
    
    public Modelica22NormalScanner() {
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

ID = {NONDIGIT} ({DIGIT}|{NONDIGIT})*
NONDIGIT = [a-zA-Z_]
DIGIT = [0-9]
UNSIGNED_INTEGER = {DIGIT} {DIGIT}*
UNSIGNED_NUMBER = {DIGIT} {DIGIT}* ( "." ( {UNSIGNED_INTEGER} )? )? ( (e|E) ( "+" | "-" )? {UNSIGNED_INTEGER} )? | {DIGIT}* ( "." ( {UNSIGNED_INTEGER} )? )?

LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]

WhiteSpace = ({LineTerminator} | [ \t\f])+

Keyword = "annotation" | "class" | "model" | "block" | "connector" | "type" | "package" | 
          "function" | "record" | "end" | "external" | "public" | "protected" | "extends" | 
          "flow" | "discrete" | "parameter" | "constant" | "input" | "output" | "initial" | 
          "equation" | "algorithm" | "each" | "final" | "replaceable" | "redeclare" | 
          "import" | "encapsulated" | "partial" | "inner" | "outer" | "and" | "or" | 
          "not" | "true" | "false" | "if" | "then" | "else" | "elseif" | "for" | "loop" | 
          "in" | "while" | "when" | "elsewhen" | "return" | "connect" | "time" | "within" | 
          "constrainedby"
          
Operator = "(" | ")" | "{" | "}" | "[" | "]" | ";" | ":" | "." | "," | "+" | "-" | "*" | 
           "/" | "=" | "^" | "<" | "<=" | ">" | ">=" | "==" | "<>"
Normal = {Operator} | {ID} | {UNSIGNED_NUMBER}

Comment = "//" {InputCharacter}* {LineTerminator}?


NONDIGIT = [a-zA-Z_]
DIGIT = [0-9]
S_CHAR = [^\"\\]
Q_CHAR = [^\'\\]
S_ESCAPE = "\\\'" | "\\\"" | "\\?" | "\\\\" | "\\a" | "\\b" | "\\f" | "\\n" | "\\r" | "\\t" | "\\v"

NL = \r|\n|\r\n
WS = ({NL} | [ \t\f])+
QIdentCont = ({Q_CHAR}|{S_ESCAPE})*
QIdent = "\'" {QIdentCont} "\'"
NormalID = {NONDIGIT} ({DIGIT}|{NONDIGIT})*
ID = {NormalID} | {QIdent}


%state COMMENTSTATE, COMMENT_ONE_LINE

%%

<YYINITIAL> {
	{Keyword}     { return KEYWORD; }
	{WhiteSpace}  { return NORMAL; }
	{Normal}      { return NORMAL; }
	"//"		  { yybegin(COMMENT_ONE_LINE); return COMMENT_BOUNDARY; }
	{ID}	      { return NORMAL; }
	.             { return NORMAL; }
}	

<COMMENT_ONE_LINE> {
 	.*				{ yybegin(YYINITIAL); System.out.println("!@!@!" + yytext()); return COMMENT; }
}

<COMMENTSTATE> {
	"\\" . 			{ return COMMENT; }
	"*/"			{ yybegin(YYINITIAL); return COMMENT_BOUNDARY; }
	[^*/\\]+		{ System.out.println("HERE!" + yytext()); return COMMENT; }
}

<<EOF>>      		{ return Token.EOF; }


