package org.jmodelica.parser;

import java.util.HashMap;
import beaver.Symbol;
import beaver.Scanner;
import org.jmodelica.parser.ModelicaParser.Terminals;

%%

%public
%final
%class ModelicaScanner
%extends Scanner
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
  StringBuffer string = new StringBuffer(128);

  private Symbol newSymbol(short id) {
    return new Symbol(id, yyline + 1, yycolumn + 1, yylength(), yytext());
  }

  private Symbol newSymbol(short id, Object value) {
    return new Symbol(id, yyline + 1, yycolumn + 1, yylength(), value);
  }
  
  public int offset() {
    return yychar;
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

  private HashMap offsets = new java.util.LinkedHashMap();

  public HashMap offsets() { 
    return offsets; 
  }

  private void registerOffset() {
    Integer key = new Integer(yyline + 2);
    Integer value = new Integer(yychar + yylength());
    offsets.put(key, value);
  }

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
InputCharacter = [^\r\n]

NonNLWhiteSpace = [ \t\f]
WhiteSpace = {LineTerminator} | {NonNLWhiteSpace}

/* comments */
Comment = {TraditionalComment} | {EndOfLineComment} 

TraditionalComment = "/*" [^*] ~"*/" | "/*" "*"+ "/"
EndOfLineComment = "//" {InputCharacter}* {LineTerminator}?



%%

<YYINITIAL> {
  "class"           { return newSymbol(Terminals.CLASS); }  
  "model"           { return newSymbol(Terminals.MODEL); }
  "block"           { return newSymbol(Terminals.BLOCK); }
  "connector"       { return newSymbol(Terminals.CONNECTOR); }
  "type"            { return newSymbol(Terminals.TYPE); }
  "package"         { return newSymbol(Terminals.PACKAGE); }
    "function"        { return newSymbol(Terminals.FUNCTION); }
    "record"        { return newSymbol(Terminals.RECORD); }
  
  "end"             { return newSymbol(Terminals.END); }
  "external"             { return newSymbol(Terminals.EXTERNAL); }
  
  
  "public"         { return newSymbol(Terminals.PUBLIC); }
  "protected"      { return newSymbol(Terminals.PROTECTED); }
  
  "extends"         { return newSymbol(Terminals.EXTENDS); }

  "flow"            { return newSymbol(Terminals.FLOW); }
   "discrete"       { return newSymbol(Terminals.DISCRETE); }
  "parameter"       { return newSymbol(Terminals.PARAMETER); }
  "constant"        { return newSymbol(Terminals.CONSTANT); }
  "input"           { return newSymbol(Terminals.INPUT); }
  "output"          { return newSymbol(Terminals.OUTPUT); }
  
  "initial"         { return newSymbol(Terminals.INITIAL); }
  "equation"        { return newSymbol(Terminals.EQUATION); }
  "initial" {WhiteSpace}+ "equation"        { return newSymbol(Terminals.INITIAL_EQUATION); }
  "algorithm"        { return newSymbol(Terminals.ALGORITHM); }
  "initial" {WhiteSpace}+ "algorithm"        { return newSymbol(Terminals.INITIAL_ALGORITHM); }
  
    "each"        { return newSymbol(Terminals.EACH); }
    "final"        { return newSymbol(Terminals.FINAL); }   
    "replaceable"        { return newSymbol(Terminals.REPLACEABLE); }
    "redeclare"        { return newSymbol(Terminals.REDECLARE); }
    "annotation"        { return newSymbol(Terminals.ANNOTATION); }
    "import"        { return newSymbol(Terminals.IMPORT); }
    "encapsulated"        { return newSymbol(Terminals.ENCAPSULATED); }
    "partial"        { return newSymbol(Terminals.PARTIAL); }
    "inner"        { return newSymbol(Terminals.INNER); }
    "outer"        { return newSymbol(Terminals.OUTER); }
    
    "and"        { return newSymbol(Terminals.AND); }
     "or"        { return newSymbol(Terminals.OR); }
     "not"        { return newSymbol(Terminals.NOT); }
     "true"        { return newSymbol(Terminals.TRUE); }
     "false"        { return newSymbol(Terminals.FALSE); }
     
     "if"        { return newSymbol(Terminals.IF); }
     "then"        { return newSymbol(Terminals.THEN); }
     "else"        { return newSymbol(Terminals.ELSE); }
     "elseif"        { return newSymbol(Terminals.ELSEIF); }
     
     "for"      { return newSymbol(Terminals.FOR); }
     "loop"      { return newSymbol(Terminals.LOOP); }
     "in"      { return newSymbol(Terminals.IN); }
     
     "while"      { return newSymbol(Terminals.WHILE); }

	 "when"      { return newSymbol(Terminals.WHEN); }
	 "elsewhen"      { return newSymbol(Terminals.ELSEWHEN); }
	 
//	 "break"      { return newSymbol(Terminals.BREAK); }
	 "return"      { return newSymbol(Terminals.RETURN); }
 
 "connect"         { return newSymbol(Terminals.CONNECT); }
 "time"         { return newSymbol(Terminals.TIME); }
 
  
  
  "("               { return newSymbol(Terminals.LPAREN); }
  ")"               { return newSymbol(Terminals.RPAREN); }
  "{"               { return newSymbol(Terminals.LBRACE); }
  "}"               { return newSymbol(Terminals.RBRACE); }
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

  "<"              { return newSymbol(Terminals.LT); }  
  "<="              { return newSymbol(Terminals.LEQ); }
  ">"              { return newSymbol(Terminals.GT); }
  ">="              { return newSymbol(Terminals.GEQ); }
  "=="               { return newSymbol(Terminals.EQ); }
  "<>"               { return newSymbol(Terminals.NEQ); }
  
  {STRING}  {  String s = yytext();
               s = s.substring(1,s.length()-1);
                return newSymbol(Terminals.STRING,s); }
  {ID}      { return newSymbol(Terminals.ID, yytext()); }
  //{UNSIGNED_INTEGER}  { return newSymbol(Terminals.INTEGER, yytext()); }
  {UNSIGNED_NUMBER}   { return newSymbol(Terminals.UNSIGNED_NUMBER, yytext()); }
  
  {Comment}          { return newSymbol(COMMENT); /* Will be discarded before parser. */ }
  {LineTerminator}	 { registerOffset(); 
  					   return newSymbol(WHITESPACE); /* Will be discarded before parser. */ }
  {NonNLWhiteSpace}+ { return newSymbol(WHITESPACE); /* Will be discarded before parser. */ }

}

//.|\n                { throw new RuntimeException("Illegal character \""+yytext()+ "\" at line "+yyline+", column "+yycolumn); }
.|\n                { throw new Scanner.Exception(yyline,yycolumn,"Illegal character \""+yytext()+ "\" at line "+yyline+", column "+yycolumn); }
<<EOF>>             { return newSymbol(Terminals.EOF); }


