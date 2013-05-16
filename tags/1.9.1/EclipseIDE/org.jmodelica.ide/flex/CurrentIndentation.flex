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
import java.util.*;
import java.io.Reader;
import java.io.StringReader;

import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.helpers.BackwardsDocumentReader;
import org.jmodelica.ide.scanners.IndentationScanner;
import org.jmodelica.ide.editor.editingstrategies.IndentationStrategy.Indent;

/**
 * Scanner for determining the current and wanted indentation of the current line.
 * 
 * Scans backwards in file, so regular expressions and semantics are inverted.
 */

%%

%public
%final
%class CurrentIndentationScanner
%extends IndentationScanner
%unicode
%apiprivate
%buffer 64
%int
%char
%table

%{
	/** The id or block keyword to search for. */
    private String target;
    /** The last id or block keyword encountered. */
    private String last;
    /** The current depth while searching for class or block beginning. */
    private int depth;
    
    /** Should the indentation of the current line be changed? */
    private boolean indentCur;
    /** The contents of last is a keyword. */
    private boolean lastIsKey;
    /** The contents of target is a keyword. */
    private boolean targetIsKey;
    /** A matching class or block beginning has been found. */
    private boolean matchFound;

	/** The indent level of the line currently being scanned. */
    private int indent;
    /** The number of chars read before the current indentation starts. */
    private int indStart;
    /** The number of spaces encountered since last tab within current indentation. */ 
    private int sinceTab;
    
    /** The indentation of the line scanning started in. */
    private Indent firstIndent;
    
    /**
     * Default constructor. 
     *
     * Initializes scanner with a dummy Reader.
     */
    public CurrentIndentationScanner() {
        this(new StringReader(""));
    }
    
    /**
     * Gets the indent of the line the scanning started in.
     */ 
    public Indent getCurrentIndent() {
    	return firstIndent;
    }
	
	/**
	 * Resets the indentation counters.
	 */
	protected void noInd() {
		indent = 0;
		indStart = yychar + yylength();
		sinceTab = -1;
	}
	
	/**
	 * Saves the current indentation counters.
	 */
	protected void saveInd() {
		firstIndent.level = indent;
		firstIndent.offset = offset - yychar + 1;
		firstIndent.length = yychar - indStart;
		noInd();
	}
	
	/**
	 * Updates indentation counters when one or more spaces has been encountered.
	 */
	protected void space(int num) {
		if (sinceTab >= 0) {
			int adv = (num + (sinceTab % 4)) / tabLen;
			sinceTab += num;
			indent += adv * tabLen;
		} else {
			indent += num;
		}
	}
	
	/**
	 * Updates indentation counters when one or more tabs has been encountered.
	 */
	protected void tab(int num) {
		indent += num * tabLen;
		sinceTab = 0;
	}
	
	// From IndentationScanner
	protected int scan() throws IOException {
		depth = 1;
		indentCur = false;
		matchFound = false;
		last = null;
		target = null;
		noInd();
		firstIndent = new Indent();
		
		return yylex();
    }
 	
 	// From DocumentScanner
	protected void reset(Reader reader) {
		yyreset(reader);
	}
	
	/**
	 * Updates the last id or block keyword encountered with the last scanned text.
	 *
	 * @param isKey  indicates if the text is a keyword
	 */
	private void setLast(boolean isKey) {
		noInd(); 
		last = yytext();
		lastIsKey = isKey;
		indentCur = false;
	}
	
	/**
	 * Called when "end" is encountered after an identifier or block keyword, 
	 * in the line the scanning starts in.
	 * 
	 * Copies <code>last</code> to <code>target</code>.
	 */
	private void curEnd() {
		noInd();
		target = last;
		targetIsKey = lastIsKey;
		indentCur = true;
	}
	
	/**
	 * Called when the start of a block or class is found.
	 * 
	 * Updates <code>level</code> and possibly <code>matchFound</code>.
	 */
	private void doLevelOut() {
		if (targetIsKey == lastIsKey && (target == null || target.equals(last))) {
			depth--;
			if (depth <= 0)
				matchFound = true; 
		}
	}
	
	/**
	 * Called when the end of a block or class is found.
	 * 
	 * Updates <code>level</code>.
	 */
	private void doLevelIn() {
		if (targetIsKey == lastIsKey && (target == null || target.equals(last))) 
			depth++;
	}

%}

NONDIGIT = [a-zA-Z_]
DIGIT = [0-9]
NormId = ({DIGIT}|{NONDIGIT})* {NONDIGIT}
QIdent = "\'" ( [^\'\\] | . "\\" )* "\'"
Id = {NormId} | {QIdent}

String = "\"" ( [^\"\\] | . "\\" )* "\""
TradComment = "/*" ~"*/"
LineComment = [^\n\r]* "//"

NewLine = \r|\n|\n\r      // We are scanning backwards, so \r\n -> \n\r


// These keywords must be backward, since we scan backwards
//       block     class     connector     function     model     package     record     type
Class = "kcolb" | "ssalc" | "rotcennoc" | "noitcnuf" | "ledom" | "egakcap" | "drocer" | "epyt" | 
//       operator     operator record     operator function
        "rotarepo" | "drocer rotarepo" | "noitcnuf rotarepo"
//     end
End = "dne"
//         public     protected     equation     algorithm
Section = "cilbup" | "detcetorp" | "noitauqe" | "mhtirogla"
//      else
Else = "esle"
//       for     if     while     when
Block = "rof" | "fi" | "elihw" | "nehw"

%state CUR_ID, PREV, PREV_ID, PREV_EQ, PREV_BLOCK

%%

// TODO: Handle "end if" when if clause contains if expression
// TODO: Handle enter after blank line (look at previous line for current indentation)

// In line containing cursor
<YYINITIAL> {
	// On any non-whitespace, reset indentation count (setLast() & saveInd() calls noInd())
	// Should be adjusted to level of surrounding class
	{Section}       { noInd(); indentCur = true; lastIsKey = false; }
	// Should be adjusted to level of surrounding block
	{Else}          { noInd(); indentCur = true; lastIsKey = true; }
	// Might be part of end of block (for, if, etc)
	{Block}         { setLast(true); yybegin(CUR_ID); }
	// Might be part of end of class
	{Id}            { setLast(false); yybegin(CUR_ID); }
	// Save current indentation of line containing cursor, 
	// if we should change indent of current line, continue to next line to find change 
	{NewLine}       { saveInd(); yybegin(PREV); if (!indentCur) return 0; }
	// Only adjust current line if triggering phrase is at start of line
	{String}        { noInd(); indentCur = false; }
	{Class}         { noInd(); indentCur = false; }
	{TradComment}	{ noInd(); }
	^ {LineComment}	{ noInd(); }
	// Save current indentation of line containing cursor, don't change it
	<<EOF>>			{ saveInd(); return 0; }
}

// In line containing cursor, just past an identifier or block keyword
<CUR_ID> {
	// This is "end" followed by id or block keyword - we want to find matching line
	{End}           { curEnd(); }
	// Save current indentation of line containing cursor, don't change it
	<<EOF>>			{ saveInd(); return 0; }
}

// In a line before the current
<PREV> {
	// On any non-whitespace, reset indentation count (setLast() & saveInd() calls noInd())
	// Might be part of start or end of block (for, if, etc)
	{Block}         { setLast(true); yybegin(PREV_BLOCK); }
	// Might be part of start or end of class
	{Id}            { setLast(false); yybegin(PREV_ID); }
	// To prevent "package A = B;", etc, to be interpreted as the start of a class
	"="				{ noInd(); yybegin(PREV_EQ); }
	{NewLine}       { if (matchFound) return indent - firstIndent.level; else noInd(); }
	{String}        { noInd(); }
	{TradComment}	{ noInd(); }
	^ {LineComment}	{ noInd(); }
}

// In a line before the current, just past an identifier
<PREV_ID> {
	// This is the start of a class
	{Class}         { noInd(); doLevelOut(); yybegin(PREV); }
	// This is the end of a class
	{End}           { noInd(); doLevelIn(); yybegin(PREV); }
}

// In a line before the current, just past a block keyword ("for", "if", etc)
<PREV_BLOCK> {
	// This is the end of a block
	{End}           { noInd(); doLevelIn(); yybegin(PREV); }
	// The just read block keyword was the start of a block
	<<EOF>>			{ doLevelOut(); return matchFound ? indent - firstIndent.level : 0; }
}

// In a line before the current, just past "=" - to detect "package A = B;", etc
<PREV_EQ> {
	// Ignore this identifier
	{Id}            { noInd(); yybegin(PREV); }
}

// In all states, count current indentation
	" "+            { space(yylength()); }
	"\t"+           { tab(yylength()); }
	
// Common EOF rule for some states
<PREV,PREV_ID,PREV_EQ>		<<EOF>>		{ return matchFound ? indent - firstIndent.level : 0; }

// Catch-all rules (must be last)
// Ignore, but reset indentation
<YYINITIAL>			[^]		{ noInd(); indentCur = false; }
<PREV>				[^]		{ noInd(); }
// Just back out of this state
<CUR_ID>			[^]		{ yypushback(1); yybegin(YYINITIAL); }
<PREV_ID,PREV_EQ>	[^]		{ yypushback(1); yybegin(PREV); }
// The just read block keyword was the start of a block
<PREV_BLOCK>		[^]		{ yypushback(1); doLevelOut(); yybegin(PREV); }
