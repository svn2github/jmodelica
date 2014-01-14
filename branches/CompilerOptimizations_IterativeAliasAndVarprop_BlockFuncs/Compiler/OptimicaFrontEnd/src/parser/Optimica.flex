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


package org.jmodelica.optimica.parser;

import org.jmodelica.util.AbstractModelicaScanner;
import beaver.Scanner;
import beaver.Symbol;
import org.jmodelica.optimica.parser.OptimicaParser.Terminals;

%%

%public
%final
%class OptimicaScanner
%extends AbstractModelicaScanner
%unicode
%function nextTokenAll
%type Symbol
%yylexthrow Scanner.Exception
%eofval{
  return newSymbol(Terminals.EOF);
%eofval}
%line
%column
%char

%{
  private Symbol newSymbol(short id) {
    return new Symbol(id, yyline + 1, yycolumn + 1, yylength(), yytext());
  }

  private Symbol newSymbol(short id, Object value) {
    return new Symbol(id, yyline + 1, yycolumn + 1, yylength(), value);
  }
  
  
//  public int offset() {
//   return yychar;
//  }
  
  public void reset(java.io.Reader reader) {
    yyreset(reader);
  }
  
  public static final short COMMENT = -1;
  public static final short WHITESPACE = -2;
  public static final int EXTRA_TOKENS = 2;
  
  public Symbol nextToken() throws java.io.IOException, Scanner.Exception {
    Symbol res;
    do {
      res = nextTokenAll();
    } while (res.getId() < 0);
    return res;
  }

  protected int matchLine()   { return yyline; }
  protected int matchColumn() { return yycolumn; }
  protected int matchOffset() { return yychar; }
  protected int matchLength() { return yylength(); }

%}

ID = {NONDIGIT} ({DIGIT}|{NONDIGIT})* | {Q_IDENT}
NONDIGIT = [a-zA-Z_]
S_CHAR = [^\"\\]
Q_IDENT = "\'" ( {Q_CHAR} | {S_ESCAPE} ) ( {Q_CHAR} | {S_ESCAPE} )* "\'"
//Q_IDENT = "\'" ( {DIGIT}|{NONDIGIT} ) ( {DIGIT}|{NONDIGIT} )* "\'"
STRING = "\"" ({S_CHAR}|{S_ESCAPE})* "\""
Q_CHAR = [^\'\\]
S_ESCAPE = "\\\'" | "\\\"" | "\\?" | "\\\\" | "\\a" | "\\b" | "\\f" | "\\n" | "\\r" | "\\t" | "\\v"
DIGIT = [0-9]
UNSIGNED_INTEGER = {DIGIT} {DIGIT}*
UNSIGNED_NUMBER = {DIGIT} {DIGIT}* ( "." ( {UNSIGNED_INTEGER} )? )? ( (e|E) ( "+" | "-" )? {UNSIGNED_INTEGER} )? | {DIGIT}* ( "." ( {UNSIGNED_INTEGER} )? )?


LineTerminator = \r|\n|\r\n
NonBreakingWhiteSpace = [ \t\f]+
InputCharacter = [^\r\n]

WhiteSpace = ({LineTerminator} | {NonBreakingWhiteSpace})+

/* comments */
Comment = {TraditionalComment} | {EndOfLineComment} 

TraditionalComment = "/*" ~"*/"
EndOfLineComment = "//" {InputCharacter}* {LineTerminator}?


%states NORMAL

%%

<YYINITIAL> {
  "\uFEFF"        { yybegin(NORMAL); }
  .|\n            { yypushback(1); yybegin(NORMAL); }
}

<NORMAL> {
  "within"        { return newSymbol(Terminals.WITHIN); }  
  "class"         { return newSymbol(Terminals.CLASS); }  
  "model"         { return newSymbol(Terminals.MODEL); }
  "block"         { return newSymbol(Terminals.BLOCK); }
  "expandable"    { return newSymbol(Terminals.EXPANDABLE); }
  "connector"     { return newSymbol(Terminals.CONNECTOR); }
  "type"          { return newSymbol(Terminals.TYPE); }
  "package"       { return newSymbol(Terminals.PACKAGE); }
  "function"      { return newSymbol(Terminals.FUNCTION); }
  "record"        { return newSymbol(Terminals.RECORD); }
  
  "end"           { return newSymbol(Terminals.END); }
  "external"      { return newSymbol(Terminals.EXTERNAL); }
  
  
  "public"        { return newSymbol(Terminals.PUBLIC); }
  "protected"     { return newSymbol(Terminals.PROTECTED); }
  
  "extends"       { return newSymbol(Terminals.EXTENDS); }
  "constrainedby" { return newSymbol(Terminals.CONSTRAINEDBY); }

  "flow"          { return newSymbol(Terminals.FLOW); }
  "stream"        { return newSymbol(Terminals.STREAM); }

  "discrete"      { return newSymbol(Terminals.DISCRETE); }
  "parameter"     { return newSymbol(Terminals.PARAMETER); }
  "constant"      { return newSymbol(Terminals.CONSTANT); }
  "input"         { return newSymbol(Terminals.INPUT); }
  "output"        { return newSymbol(Terminals.OUTPUT); }
  
  "equation"      { return newSymbol(Terminals.EQUATION); }
  "algorithm"     { return newSymbol(Terminals.ALGORITHM); }

  "initial" {WhiteSpace} "equation"    { addLineBreaks(yytext()); 
  										 return newSymbol(Terminals.INITIAL_EQUATION); }  
  "initial" {WhiteSpace} "algorithm"   { addLineBreaks(yytext()); 
  										 return newSymbol(Terminals.INITIAL_ALGORITHM); }
  "operator" {WhiteSpace} "record"     { addWhiteSpaces(yytext());
  										 addLineBreaks(yytext());
                                         return newSymbol(Terminals.RECORD); }
  "operator" {WhiteSpace} "function"   { addWhiteSpaces(yytext());
  										 addLineBreaks(yytext()); 
                                         return newSymbol(Terminals.FUNCTION); }
  									

  "end" {WhiteSpace} "for"    { addLineBreaks(yytext()); 
                                return newSymbol(Terminals.END_FOR); }
  "end" {WhiteSpace} "while"  { addLineBreaks(yytext()); 
                                return newSymbol(Terminals.END_WHILE); }
  "end" {WhiteSpace} "if"     { addLineBreaks(yytext()); 
                                return newSymbol(Terminals.END_IF); }
  "end" {WhiteSpace} "when"   { addLineBreaks(yytext()); 
                                return newSymbol(Terminals.END_WHEN); }
  "end" {WhiteSpace} {ID}     { String s = yytext();
  			                    return newSymbol(Terminals.END_ID, s); }  										 
  					
  "enumeration"     { return newSymbol(Terminals.ENUMERATION); }
  										 
  "each"          { return newSymbol(Terminals.EACH); }
  "final"         { return newSymbol(Terminals.FINAL); }   
  "replaceable"   { return newSymbol(Terminals.REPLACEABLE); }
  "redeclare"     { return newSymbol(Terminals.REDECLARE); }
  "annotation"    { return newSymbol(Terminals.ANNOTATION); }
  "import"        { return newSymbol(Terminals.IMPORT); }
  "encapsulated"  { return newSymbol(Terminals.ENCAPSULATED); }
  "partial"       { return newSymbol(Terminals.PARTIAL); }
  "inner"         { return newSymbol(Terminals.INNER); }
  "outer"         { return newSymbol(Terminals.OUTER); }
  
  "and"           { return newSymbol(Terminals.AND); }
  "or"            { return newSymbol(Terminals.OR); }
  "not"           { return newSymbol(Terminals.NOT); }
  "true"          { return newSymbol(Terminals.TRUE); }
  "false"         { return newSymbol(Terminals.FALSE); }
  
  "if"            { return newSymbol(Terminals.IF); }
  "then"          { return newSymbol(Terminals.THEN); }
  "else"          { return newSymbol(Terminals.ELSE); }
  "elseif"        { return newSymbol(Terminals.ELSEIF); }
  
  "for"           { return newSymbol(Terminals.FOR); }
  "loop"          { return newSymbol(Terminals.LOOP); }
  "in"            { return newSymbol(Terminals.IN); }
  
  "while"         { return newSymbol(Terminals.WHILE); }

  "when"          { return newSymbol(Terminals.WHEN); }
  "elsewhen"      { return newSymbol(Terminals.ELSEWHEN); }

  "break"         { return newSymbol(Terminals.BREAK); }
  "return"        { return newSymbol(Terminals.RETURN); }
 
  "connect"       { return newSymbol(Terminals.CONNECT); }
  "time"          { return newSymbol(Terminals.TIME); }
  "der"           { return newSymbol(Terminals.DER); }
  "constraint"    { return newSymbol(Terminals.CONSTRAINT); }
  "optimization"  { return newSymbol(Terminals.OPTIMIZATION); }
  
  "("             { return newSymbol(Terminals.LPAREN); }
  ")"             { return newSymbol(Terminals.RPAREN); }
  "{"             { return newSymbol(Terminals.LBRACE); }
  "}"             { return newSymbol(Terminals.RBRACE); }
  "["             { return newSymbol(Terminals.LBRACK); }	
  "]"             { return newSymbol(Terminals.RBRACK); }	
  ";"             { return newSymbol(Terminals.SEMICOLON); }
  ":"             { return newSymbol(Terminals.COLON); }
  "."             { return newSymbol(Terminals.DOT); }
  ","             { return newSymbol(Terminals.COMMA); }
  ".+"            { return newSymbol(Terminals.DOTPLUS); }  
  ".-"            { return newSymbol(Terminals.DOTMINUS); }
  ".*"            { return newSymbol(Terminals.DOTMULT); }
  "./"            { return newSymbol(Terminals.DOTDIV); }
  ".^"            { return newSymbol(Terminals.DOTPOW); }

  "+"             { return newSymbol(Terminals.PLUS); }  
  "-"             { return newSymbol(Terminals.MINUS); }
  "*"             { return newSymbol(Terminals.MULT); }
  "/"             { return newSymbol(Terminals.DIV); }
  "="             { return newSymbol(Terminals.EQUALS); }
  ":="            { return newSymbol(Terminals.ASSIGN); }
  "^"             { return newSymbol(Terminals.POW); }

  "<"             { return newSymbol(Terminals.LT); }  
  "<="            { return newSymbol(Terminals.LEQ); }
  ">"             { return newSymbol(Terminals.GT); }
  ">="            { return newSymbol(Terminals.GEQ); }
  "=="            { return newSymbol(Terminals.EQ); }
  "<>"            { return newSymbol(Terminals.NEQ); }
  
  {STRING}  {  String s = yytext();
               addLineBreaks(s);
               s = s.substring(1,s.length()-1);
               return newSymbol(Terminals.STRING,s); }
  {ID}      { String s = yytext();
  			  addLineBreaks(s);
  			  return newSymbol(Terminals.ID, s); }
  
  {UNSIGNED_INTEGER}  { return newSymbol(Terminals.UNSIGNED_INTEGER, yytext()); }
  {UNSIGNED_NUMBER}   { return newSymbol(Terminals.UNSIGNED_NUMBER, yytext()); }
  
  {Comment}                { addLineBreaks(yytext()); }
  {NonBreakingWhiteSpace}  { }
  {LineTerminator} 		   { addLineBreak(); }
  .|\n                { throw new Exception("Illegal character \""+yytext()+ "\""); }
}

<<EOF>>             { return newSymbol(Terminals.EOF); }



