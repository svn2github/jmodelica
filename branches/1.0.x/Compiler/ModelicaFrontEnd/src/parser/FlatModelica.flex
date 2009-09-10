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
%extends Scanner
%unicode
%function nextToken
%type Symbol
%yylexthrow Scanner.Exception
%eofval{
  return newSymbol(Terminals.EOF);
%eofval}
%line
%column


%{
  StringBuffer string = new StringBuffer(128);

  private Symbol newSymbol(short id) {
    return new Symbol(id, yyline + 1, yycolumn + 1, yylength(), yytext());
  }

  private Symbol newSymbol(short id, Object value) {
    return new Symbol(id, yyline + 1, yycolumn + 1, yylength(), value);
  }

%}


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

LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]

WhiteSpace = {LineTerminator} | [ \t\f]

/* comments */
Comment = {TraditionalComment} | {EndOfLineComment} 

TraditionalComment = "/*" [^*] ~"*/" | "/*" "*"+ "/"
EndOfLineComment = "//" {InputCharacter}* {LineTerminator}?



%%

<YYINITIAL> {
//  "class"           { return newSymbol(Terminals.CLASS); }  
//   "model"           { return newSymbol(Terminals.MODEL); }
//   "block"           { return newSymbol(Terminals.BLOCK); }
//   "connector"       { return newSymbol(Terminals.CONNECTOR); }
//   "type"            { return newSymbol(Terminals.TYPE); }
//   "package"         { return newSymbol(Terminals.PACKAGE); }
//     "function"        { return newSymbol(Terminals.FUNCTION); }
//     "record"        { return newSymbol(Terminals.RECORD); }
  
  "end"             { return newSymbol(Terminals.END); }
  
//    "end" {WhiteSpace} "for"   { addLineBreaks(yytext()); 
//    return newSymbol(Terminals.END_FOR); }

//  "end" {WhiteSpace} "while"   { addLineBreaks(yytext()); 
//    return newSymbol(Terminals.END_WHILE); }

//  "end" {WhiteSpace} "if"   { addLineBreaks(yytext()); 
//    return newSymbol(Terminals.END_IF); }

//  "end" {WhiteSpace} "when"   { addLineBreaks(yytext()); 
//    return newSymbol(Terminals.END_WHEN); }
 
    "end" {WhiteSpace} {ID} { String s = yytext();
  			  return newSymbol(Terminals.END_ID, s); }
  
  
   "public"         { return newSymbol(Terminals.PUBLIC); }
   "protected"      { return newSymbol(Terminals.PROTECTED); }
  
 //  "extends"         { return newSymbol(Terminals.EXTENDS); }

   "parameter"       { return newSymbol(Terminals.PARAMETER); }
   "constant"        { return newSymbol(Terminals.CONSTANT); }
   "input"           { return newSymbol(Terminals.INPUT); }
   "output"          { return newSymbol(Terminals.OUTPUT); }
  
//  "initial"         { return newSymbol(Terminals.INITIAL); }
   "equation"        { return newSymbol(Terminals.EQUATION); }
 //  "algorithm"        { return newSymbol(Terminals.ALGORITHM); }
  
     "each"        { return newSymbol(Terminals.EACH); }
     "final"        { return newSymbol(Terminals.FINAL); }   
//     "replaceable"        { return newSymbol(Terminals.REPLACEABLE); }
//     "redeclare"        { return newSymbol(Terminals.REDECLARE); }
//     "annotation"        { return newSymbol(Terminals.ANNOTATION); }
 //    "import"        { return newSymbol(Terminals.IMPORT); }
 //    "encapsulated"        { return newSymbol(Terminals.ENCAPSULATED); }
 //    "partial"        { return newSymbol(Terminals.PARTIAL); }
 //    "inner"        { return newSymbol(Terminals.INNER); }
 //    "outer"        { return newSymbol(Terminals.OUTER); }

//  "connect"         { return newSymbol(Terminals.CONNECT); }

  "time"         { return newSymbol(Terminals.TIME); }


  
  "("               { return newSymbol(Terminals.LPAREN); }
  ")"               { return newSymbol(Terminals.RPAREN); }
 //  "{"               { return newSymbol(Terminals.LBRACE); }
 //  "}"               { return newSymbol(Terminals.RBRACE); }
   "["               { return newSymbol(Terminals.LBRACK); }	
   "]"               { return newSymbol(Terminals.RBRACK); }	
   ";"               { return newSymbol(Terminals.SEMICOLON); }
   ":"               { return newSymbol(Terminals.COLON); }
   "."               { return newSymbol(Terminals.DOT); }
   ","               { return newSymbol(Terminals.COMMA); }


   "+"              { return newSymbol(Terminals.PLUS); }  
   "-"              { return newSymbol(Terminals.MINUS); }
   "*"              { return newSymbol(Terminals.MULT); }
  "/"              { return newSymbol(Terminals.DIV); }
  "="               { return newSymbol(Terminals.ASSIGN); }
  "^"               { return newSymbol(Terminals.POW); }

  
  {STRING}  {  String s = yytext();
               s = s.substring(1,s.length()-1);
                return newSymbol(Terminals.STRING,s); }
  {ID}      { return newSymbol(Terminals.ID, yytext()); }
  //{UNSIGNED_INTEGER}  { return newSymbol(Terminals.INTEGER, yytext()); }
  {UNSIGNED_NUMBER}   { return newSymbol(Terminals.UNSIGNED_NUMBER, yytext()); }
  
  {Comment}         { /* discard token */ }
  {WhiteSpace}      { /* discard token */ }

}

//.|\n                { throw new RuntimeException("Illegal character \""+yytext()+ "\" at line "+yyline+", column "+yycolumn); }
.|\n                { throw new Scanner.Exception(yyline,yycolumn,"Illegal character \""+yytext()+ "\" at line "+yyline+", column "+yycolumn); }
<<EOF>>             { return newSymbol(Terminals.EOF); }


