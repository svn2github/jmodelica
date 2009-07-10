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
import java.io.StringReader;

%%

%public
%final
%class IndentationKeywordScanner
%unicode
%buffer 256
%type void
%char
%table

%{
	String keyword = null;
	String id = null;
	boolean mend, mbeg;
	
    public IndentationKeywordScanner() {
        this(new StringReader(""));
    }
    
    public void match(String line) {
        yyreset(new StringReader(line));
        id = null;
        mend = mbeg = false;
        try {
			yylex();
		} catch (IOException e) {
		}
    }
    //equations, public etc. are considered as end blocks 
    public boolean matchesBeginBlock() {
    	return mbeg;
    }
    public boolean matchesEndBlock() {
    	return mend;
    }
    
    public String getId() {
    	return id;
    }
    public String getKeyword() {
    	return keyword;
    }	
   
%}

NONDIGIT = [a-zA-Z_]
DIGIT = [0-9]
INTEGER = {DIGIT} {DIGIT}*
FRAC = "." ( {INTEGER} )?
EXP = (e|E) ( "+" | "-" )? {INTEGER}
NUMBER = ( {DIGIT}+ {FRAC}? | {FRAC} ) {EXP}?
NormId = {NONDIGIT} ({DIGIT}|{NONDIGIT})*
QIdent = "\'" ([^\'\\] | "\\" .)* "\'"
String = "\"" ([^\"\\] | "\\" .)* "\""
Id = {NormId} | {QIdent}
LineComment = "//" [^\n\r]*
TradComment = "/*" ~"*/"
WhiteSpace = [ \t]+
Operator = "(" | ")" | "{" | "}" | "[" | "]" | ";" | ":" | "." | "," | "+" | "-" | "*" | 
           "/" | "=" | "^" | "<" | "<=" | ">" | ">=" | "==" | "<>"
Ignore = {WhiteSpace} | {TradComment} | {Id} | {String} | {NUMBER} | {Operator}

NewBlock =  "block" | "class" | "connector" | "function" | "model" | "package" | "record" | "type"
SepBlock = "equation" | "algorithm" | "public" | "protected"
EndBlock =  "end"

%state IDENT

%%
{WhiteSpace} {}
<<EOF>> { return; }

<YYINITIAL> {
	{NewBlock} { 
  		mbeg = true;
  		keyword = yytext();
  		yybegin(IDENT); 
	}
	{SepBlock} { 
		mend = true; 
		keyword = yytext();
		return;
	}
	{EndBlock} {
		mend = true;
		keyword = yytext();
		yybegin(IDENT);
	}  					
}

<IDENT> {
	{Id} {
		id = yytext();
		return;
	}
}

.|\n { return; }