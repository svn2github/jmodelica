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
    private IToken last_token;
    
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
        last_token = ANNOTATION_NORMAL;
    	reset(document, offset, length);	
    }
    
    protected void reset(Reader r) {
        yyreset(r);
    }
    
    protected IToken rtn(IToken token) {
    	last_token = token;
    	return token;
    }
%}
							//note: below ID includes dot
ID = {NONDIGIT} ({DIGIT}|{NONDIGIT}|".")* | {Q_IDENT}
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

NNLWhiteSpace = [ \t\f]
WhiteSpace = ({LineTerminator} | [ \t\f])

Keyword = "each" | "final" | "replaceable" | "redeclare" | "and" | "or" | "not" | 
          "true" | "false" | "if" | "then" | "else" | "elseif" | "end" | "for" | 
          "flow" | "discrete" | "parameter" | "constant" | "input" | "output"
          
Operator = "(" | ")" | "{" | "}" | "[" | "]" | ";" | ":" | "." | "," | "+" | "-" | "*" | 
           "/" | "=" | "^" | "<" | "<=" | ">" | ">=" | "==" | "<>"
Normal = {ID} | {UNSIGNED_NUMBER}

TraditionalComment = "/*" ([^*]* | "*" [^/])* "*/"
EndOfLineComment = "//" {InputCharacter}* {LineTerminator}?
Comment = {TraditionalComment} | {EndOfLineComment} 

%state COMMENTSTATE, COMMENT_ONE_LINE

%%

<YYINITIAL> {
	{Keyword}                     { return rtn(ANNOTATION_KEYWORD); }
	{LineTerminator}{WhiteSpace}* { return rtn(ANNOTATION_NORMAL); }
	{NNLWhiteSpace}+              { return rtn(last_token); }
	{ID} {WhiteSpace}* / "="	  { return rtn(ANNOTATION_LHS); }				  
	{ID} {WhiteSpace}* / "("	  { return rtn(ANNOTATION_RHS); }				  
	{Operator}+                   { return rtn(ANNOTATION_OPERATOR); }
	{Normal}                      { return rtn(ANNOTATION_NORMAL); }
	{STRING}                      { return rtn(ANNOTATION_STRING); }
	"/*"                          { yybegin(COMMENTSTATE); return rtn(COMMENT_BOUNDARY); }
	"//"                          { yybegin(COMMENT_ONE_LINE); return rtn(COMMENT_BOUNDARY); }
	.                             { return rtn(ANNOTATION_NORMAL); }
}

<COMMENT_ONE_LINE> {
	[^]*				    	  { yybegin(YYINITIAL); return rtn(COMMENT); }
}

<COMMENTSTATE> {
	{LineTerminator}{WhiteSpace}* 
				      			  { return rtn(ANNOTATION_NORMAL); }
	"\\" .                        { return rtn(COMMENT); }
	"*/"                          { yybegin(YYINITIAL); return rtn(COMMENT_BOUNDARY); }
	[^\\*/\n\r]+                  { return rtn(COMMENT); }
	[^]							  { return rtn(last_token); }
}

<<EOF>>                           { return rtn(Token.EOF); }
