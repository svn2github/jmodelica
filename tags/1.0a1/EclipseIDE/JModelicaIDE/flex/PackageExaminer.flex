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

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.io.StringReader;

import org.jmodelica.ide.helpers.Library;

%%

%public
%final
%class PackageExaminer
%unicode
%buffer 1024
%int
%apiprivate
%char
%table

%{
	private Library lib;
	private int level;
	
    public PackageExaminer() {
        this(new StringReader(""));
    }
    
    public Library examine(String path) throws FileNotFoundException {
    	StringBuilder filePath = new StringBuilder(path);
    	if (!path.endsWith(File.separator))
    		filePath.append(File.separator);
    	filePath.append("package.mo");
    	FileReader reader = new FileReader(filePath.toString());
    	lib = new Library();
    	lib.path = path;
    	lib.name = "";
    	lib.version = new Library.Version("");
		yyreset(reader);	
        try {
			yylex();
		} catch (IOException e) {
		}
		return lib;
    }
%}

NormID = {NONDIGIT} ({DIGIT}|{NONDIGIT})*
NONDIGIT = [a-zA-Z_]
DIGIT = [0-9]
UNSIGNED_INTEGER = {DIGIT} {DIGIT}*
UNSIGNED_NUMBER = {DIGIT} {DIGIT}* ( "." ( {UNSIGNED_INTEGER} )? )? ( (e|E) ( "+" | "-" )? {UNSIGNED_INTEGER} )? | {DIGIT}* ( "." ( {UNSIGNED_INTEGER} )? )?

LineTerminator = \r|\n|\r\n
WhiteSpace = ({LineTerminator} | [ \t\f])+

Keyword = "end" | "external" | "public" | "protected" | "extends" | 
          "flow" | "discrete" | "parameter" | "constant" | "input" | "output" | "initial" | 
          "equation" | "algorithm" | "each" | "final" | "replaceable" | "redeclare" | 
          "import" | "encapsulated" | "partial" | "inner" | "outer" | "and" | "or" | 
          "not" | "true" | "false" | "if" | "then" | "else" | "elseif" | "for" | "loop" | 
          "in" | "while" | "when" | "elsewhen" | "return" | "connect" | "time" | "constrainedby"
Class = "block" | "class" | "connector" | "function" | "model" | "record" | "type" | "package"
Operator = "(" | ")" | "{" | "}" | "[" | "]" | ";" | ":" | "." | "," | "+" | "-" | "*" | 
           "/" | "=" | "^" | "<" | "<=" | ">" | ">=" | "==" | "<>"

Normal = {Keyword} | {Operator} | {ID} | {UNSIGNED_NUMBER} | {String}
String = "\"" ( [^\"\\] | "\\" . )* "\""
QIdent = "\'"( [^\'\\] | "\\" . )* "\'"
ID = {NormID} | {QIdent}
Comment = ("/*" ~"*/") | ("//" ~(\n|\r|\n\r))
CompoundID = {ID} ("." {ID})*
Version = "version" ({WhiteSpace} | {Comment})* "="

%state PACKAGE, WITHIN, INPACKAGE, ANNOTATION, VERSION

%%

<YYINITIAL> {
	"package"			{ yybegin(PACKAGE); }
	"within"			{ yybegin(WITHIN); }
	{ID}				{ return 0; }
}

<WITHIN> {
	";"					{ yybegin(YYINITIAL); }
	{CompoundID}		{ lib.name = yytext(); yybegin(YYINITIAL); }
}

<PACKAGE> {
	{ID}				{ level = 0; lib.name += yytext(); yybegin(INPACKAGE); }
}

<INPACKAGE> {
	"annotation"		{ if (level == 0) yybegin(ANNOTATION); }
	{Class}				{ level++; }
	"end"				{ level--; }
	{Normal}			{ }
}

<ANNOTATION> {
	{Version}			{ if (level == 1) yybegin(VERSION); }
	"("					{ level++; }
	")"					{ level--; }
	{Normal}			{ }
}

<VERSION> {
	{String}			{ lib.version = new Library.Version(yytext().replace('"', ' ').trim()); return 0; }
}

{Comment}				{ }
{WhiteSpace}			{ }
<<EOF>>					{ return 0; }
.|{LineTerminator}		{ return 0; }
