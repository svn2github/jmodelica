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

%%

{Keyword}     { return KEYWORD; }
{WhiteSpace}  { return NORMAL; }
{Normal}      { return NORMAL; }
{Comment}     { return COMMENT; }
.             { return NORMAL; }
<<EOF>>       { return Token.EOF; }
