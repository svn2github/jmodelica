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

import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;

import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.helpers.BackwardsDocumentReader;
import org.jmodelica.ide.scanners.IndentationScanner;
import org.jmodelica.ide.editor.editingstrategies.IndentationStrategy.Indent;

/**
 * Scanner for determining the wanted indentation of the new line when enter is pressed.
 * 
 * Scans backwards in file, so regular expressions and semantics are inverted.
 */

%%

%public
%final
%class NextIndentationScanner
%extends IndentationScanner
%unicode
%apiprivate
%buffer 64
%int
%char
%table

%{
	/** Line number, counted from 0 for the line scanning starts in. */
    private int line;
    /** If line before current line contains a keyword that prompts indentation. */
    private boolean indentKey;
    
    /**
     * Default constructor. 
     *
     * Initializes scanner with a dummy Reader.
     */
    public NextIndentationScanner() {
        this(new StringReader(""));
    }
	
	// From IndentationScanner
	protected int scan() throws IOException {
		line = 0;
		indentKey = false;
		return yylex();
   }
 	
 	// From DocumentScanner
	protected void reset(Reader reader) {
		yyreset(reader);
	}
	
	/**
	 * Calculate sought indentation change once we have needed info.
	 */
	protected int calcWantedChange() {
		if (indentKey || line == 1) 
			return stepLen;
		return 0;
	}

%}

QIdent = "\'" ( [^\'\\] | . "\\" )* "\'"
String = "\"" ( [^\"\\] | . "\\" )* "\""
TradComment = "/*" ~"*/"
LineComment = [^\n\r]* "//"
IdOrNum = [_a-zA-Z0-9]+
Ignore = {String} | {TradComment} | {QIdent} | {IdOrNum}


Whitespace = [ \t\r\n]+
NewLine = \r|\n|\n\r

// These keywords must be backward, since we scan backwards
//       block     class     connector     function     model     package     record     type
Class = "kcolb" | "ssalc" | "rotcennoc" | "noitcnuf" | "ledom" | "egakcap" | "drocer" | "epyt" | 
//       operator     operator record     operator function
        "rotarepo" | "drocer rotarepo" | "noitcnuf rotarepo"
//         public     protected     equation     algorithm     else
Section = "cilbup" | "detcetorp" | "noitauqe" | "mhtirogla" | "esle"
//       for     if     while     when
Block = "rof" | "fi" | "elihw" | "nehw"

IndentKey = {Class} | {Section} | {Block}

// TODO: Handle empty lines (only whitespace)
// TODO: Handle stepping back after expression indent.
/* Example:
	x = y + 2 *
	    z + 4;  // Enter here should end up ...
    // here
*/
// TODO: It might be possible to return earlier.

%state LINE, PREV_END

%%

// Just before cursor (or past some whitespace and/or comments)
<YYINITIAL> {
	";"             { return 0; }  // Same indent as last line
}

// End of a line before the current
<PREV_END> {
	";"             { return calcWantedChange(); }
}

<YYINITIAL, PREV_END> {
	{Whitespace}    { }
	{TradComment}	{ }
	^ {LineComment}	{ }
	.               { yypushback(1); yybegin(LINE); }
}

// In a line (before the last non-whitespace, non-comment char)
<LINE> {
	{IndentKey}		{ if (line == 1) indentKey = true; }
	{NewLine}+      { yybegin(PREV_END); line++; }
	{Ignore}+       { }
	.               { }
}

<<EOF>>         	{ return calcWantedChange(); }
