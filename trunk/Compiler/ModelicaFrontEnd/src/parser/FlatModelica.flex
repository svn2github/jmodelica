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


%%

%public
%final
%class FlatModelicaScanner
%unicode
%function nextToken
%type String
%yylexthrow RuntimeException
%eofval{
  return null;
%eofval}
%line
%column


ID = {NONDIGIT} ({DIGIT}|{NONDIGIT})* | {Q_IDENT}
//IDWD = {NONDIGITWD} ({DIGIT}|{NONDIGITWD})* | {Q_IDENT}
NONDIGIT = [a-zA-Z_]
//NONDIGITWD = [a-zA-Z_.]
S_CHAR = [^\"\\]
Q_IDENT = "'" ( {Q_CHAR} | {S_ESCAPE} ) ( {Q_CHAR} | {S_ESCAPE} )* "'"
//Q_IDENT = "'" ( {DIGIT}|{NONDIGITWD} ) ( {DIGIT}|{NONDIGITWD} )* "'"
STRING = "\"" ({S_CHAR}|{S_ESCAPE})* "\""
Q_CHAR = !("'"|"\\")
S_ESCAPE = "\\\'" | "\\\"" | "\\?" | "\\\\" | "\\a" | "\\b" | "\\f" | "\\n" | "\\r" | "\\t" | "\\v"
DIGIT = [0-9]
UNSIGNED_INTEGER = {DIGIT} {DIGIT}*
UNSIGNED_NUMBER = {UNSIGNED_INTEGER} ( "." ( {UNSIGNED_INTEGER} )? )? ( (e|E) ( "+" | "-" )? {UNSIGNED_INTEGER} )?

Separators = "(" | ")" | "[" | "]" | "{" | "}" | ";" | ":" | "." | ","
Arithmetic = "+" | "-" | "*" | "/" | "^"
Assign     = "=" | ":="
Compare    = "==" | "!=" | "<" | "<=" | ">" | ">="

Operator = {Separators} | {Arithmetic} | {Assign} | {Compare}

LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]

WhiteSpace = {LineTerminator} | [ \t\f]

/* comments */
Comment = {TraditionalComment} | {EndOfLineComment} 

TraditionalComment = "/*" [^*] ~"*/" | "/*" "*"+ "/"
EndOfLineComment = "//" {InputCharacter}* {LineTerminator}?

Token   = {STRING} | {ID} | {UNSIGNED_NUMBER} | {Operator}
Discard = {Comment} | {WhiteSpace}

%%

{Token}             { return yytext(); }
{Discard}           { }
.                   { return "$ Bad character '" + yytext() + "' $"; }
<<EOF>>             { return null; }
