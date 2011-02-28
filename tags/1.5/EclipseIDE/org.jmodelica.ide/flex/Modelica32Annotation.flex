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
%class Modelica32AnnotationScanner
%extends HilightScanner
%unicode
%buffer 2048
%function nextTokenInternal
%apiprivate
%type IToken
%char
%pack

%{
    private int start;
    private IToken last_token;
    
    public Modelica32AnnotationScanner() {
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

NONDIGIT = [a-zA-Z_]
DIGIT = [0-9]
INTEGER = {DIGIT} {DIGIT}*
S_CHAR = [^\"\\]
Q_CHAR = [^\'\\]
S_ESCAPE = "\\\'" | "\\\"" | "\\?" | "\\\\" | "\\a" | "\\b" | "\\f" | "\\n" | "\\r" | "\\t" | "\\v"

Number = {INTEGER} ( "." ( {INTEGER} )? )? ( (e|E) ( "+" | "-" )? {INTEGER} )? | {DIGIT}* ( "." ( {INTEGER} )? )?

LineTerminator = \r|\n|\r\n
WhiteSpace = ({LineTerminator} | [ \t\f])+

// This is the table in section 2.3.3 in MLS v3.2
// commented-out keywords are in other categories 
Keyword = "algorithm"     | "discrete"   /* | "false"      */ | "model"         | "redeclare"     | 
          "and"           | "each"          | "final"         | "not"           | "replaceable"   | 
          "annotation"    | "else"          | "flow"          | "operator"      | "return"        | 
          "assert"        | "elseif"        | "for"           | "or"            | "stream"        | 
          "block"         | "elsewhen"      | "function"      | "outer"         | "then"          | 
          "break"         | "encapsulated"  | "if"            | "output"     /* |  "true"      */ | 
          "class"         | "end"           | "import"        | "package"       | "type"          | 
          "connect"       | "enumeration"   | "in"            | "parameter"     | "when"          | 
          "connector"     | "equation"      | "initial"       | "partial"       | "while"         | 
          "constant"      | "expandable"    | "inner"         | "protected"     | "within"        | 
          "constrainedby" | "extends"       | "input"         | "public"        | 
          "der"           | "external"      | "loop"          | "record"

// Extra stuff we want to color as keywords.
ExtraKeyword = "time" 

// Built-in functions (a.k.a. function-like operators)
          // MSL 3.2, sect 3.7.1, p 20
BuiltIn = "abs" | "sign" | "sqrt" | 
          // MSL 3.2, sect 3.7.1.1, p 21
          "div" | "mod" | "rem" | "ceil" | "floor" | "integer" | "Integer" | "String" | 
          // MSL 3.2, sect 3.7.1.2, p 21-22
          "sin" | "cos" | "tan" | "asin" | "acos" | "atan" | "atan2" | "sinh" | "cosh" | "tanh" | "exp" | "log" | "log10" | 
          // MSL 3.2, sect 3.7.2, p 22-23
          "delay" | "homotopy" | "semiLinear" | "Subtask.decouple" | 
          // MSL 3.2, sect 3.7.3, p 26-27
          "initial" | "terminal" | "noEvent" | "smooth" | "sample" | "pre" | "edge" | "change" | "reinit" | 
          // MSL 3.2, sect 10.3.1, p 110
          "ndims" | "size" | 
          // MSL 3.2, sect 10.3.2, p 110
          "scalar" | "vector" | "matrix" | 
          // MSL 3.2, sect 10.3.3, p 110-111
          "identity" | "diagonal" | "zeros" | "ones" | "fill" | "linspace" | 
          // MSL 3.2, sect 10.3.4, p 111
          "min" | "max" | "sum" | "product" | 
          // MSL 3.2, sect 10.3.5, p 112
          "transpose" | "outerProduct" | "symmetric" | "cross" | "skew" | 
          // MSL 3.2, sect 16.6, p 185
          "Subtask.activated", "Subtask.lastInterval"

DeprBuiltIn = "cardinality"

FuncParen = {WhiteSpace}? "("

// Built-in types
Type = "Real" | "Boolean" | "Integer" | "String"

// All non-keyword non-function-like operators
Operator = "(" | ")" | "{" | "}" | "[" | "]" | ";" | ":" | /* "." | */ "," |
           "+" | "-" | "*" | "/" | ".^" | ".+" | ".-" | ".*" | "./" | ".^" | 
           "=" | "<" | "<=" | ">" | ">=" | "==" | "<>"


Boolean = "true" | "false"

String = "\"" ({S_CHAR}|{S_ESCAPE})* "\""

QID = "\'" ({Q_CHAR}|{S_ESCAPE})+ "\'"
ID = {NONDIGIT} ({DIGIT}|{NONDIGIT})*

OkIdInDotted = {BuiltIn} | {DeprBuiltIn} | {Type}

TraditionalComment = "/*" ~"*/"
EndOfLineComment = "//" [^\n\r]* {LineTerminator}?
Comment = {TraditionalComment} | {EndOfLineComment} 


%state INSIDE, AFTER_ID, AFTER_DOT

%%

<YYINITIAL> {
    "annotation"    { return KEYWORD; }
    "("             { yybegin(INSIDE); return ANNO_OPERATOR; }
    .               { return NORMAL; }
}

<INSIDE> {
    {Keyword}       { return ANNO_KEYWORD; }
    {ExtraKeyword}  { return ANNO_EXTRA_KEYWORD; }
    {BuiltIn} / {FuncParen}     { return ANNO_BUILT_IN; }
    {DeprBuiltIn} / {FuncParen} { return ANNO_DEPR_BUILT_IN; }
    {Type}          { return ANNO_TYPE; }
    {Operator}      { return ANNO_OPERATOR; }
    {Boolean}       { return ANNO_BOOLEAN; }
    {Number}        { return ANNO_NUMBER; }
    {String}        { return ANNO_STRING; }
    {ID}	        { yybegin(AFTER_ID); return ANNO_ID; }
    {QID}	        { yybegin(AFTER_ID); return ANNO_QID; }
    {Comment}       { return ANNO_COMMENT; }
    {WhiteSpace}    { return ANNO_NORMAL; }
    .               { return ANNO_NORMAL; }
}

<AFTER_ID> {
    {Comment}       { return ANNO_COMMENT; }
    "."             { yybegin(AFTER_DOT); return ANNO_OPERATOR_DOT; }
    {WhiteSpace}    { return ANNO_NORMAL; }
    .               { yybegin(INSIDE); yypushback(1); }
}

<AFTER_DOT> {       
    {Comment}       { return ANNO_COMMENT; }
    {ID}	        { yybegin(AFTER_ID); return ANNO_ID; }
    {OkIdInDotted}  { yybegin(AFTER_ID); return ANNO_ID; }
    {QID}	        { yybegin(AFTER_ID); return ANNO_QID; }
    {WhiteSpace}    { return ANNO_NORMAL; }
    .               { yybegin(INSIDE); yypushback(1); }
}

<<EOF>>             { return Token.EOF; }
