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

import java.io.Reader;
import java.io.StringReader;

import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.rules.IPartitionTokenScanner;
import org.eclipse.jface.text.rules.IToken;
import org.eclipse.jface.text.rules.Token;

import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.scanners.DocumentScanner;

%%

%public
%final
%class Modelica22PartitionScanner
%extends DocumentScanner
%implements IPartitionTokenScanner
%unicode
%function nextTokenInternal
%apiprivate
%type IToken
%char
%table

%{
    private static final String PARTITION = IDEConstants.PLUGIN_ID + ".partition";
    public static final String NORMAL_PARTITION = PARTITION + ".normal";
    public static final String STRING_PARTITION = PARTITION + ".string";
    public static final String QIDENT_PARTITION = PARTITION + ".qident";
    public static final String ANNOTATION_PARTITION = PARTITION + ".annotation";
    public static final String COMMENT_PARTITION = PARTITION + ".comment";
    public static final String DEFINITION_PARTITION = PARTITION + ".definition";

    public static final String[] LEGAL_PARTITIONS = { 
        NORMAL_PARTITION, STRING_PARTITION, QIDENT_PARTITION, 
        ANNOTATION_PARTITION, COMMENT_PARTITION, DEFINITION_PARTITION
        };
    
    private int offset;
    private int start;
    private int saveOffset;
    private int level;
    
    public Modelica22PartitionScanner() {
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
        return yychar - offset + yylength();
    }

    public int getTokenOffset() {
        return start + offset;
    }

    public void setRange(IDocument document, int offset, int length) {
        start = offset;
        reset(document, offset, length);    
    }

    public void setPartialRange(IDocument document, int offset, int length,
            String contentType, int partitionOffset) {
        boolean restart = false;
        int state = YYINITIAL;
        if (offset > partitionOffset) {
            if (contentType == NORMAL_PARTITION) {
                state = NORMAL;
            } else if (contentType == STRING_PARTITION) { 
                state = STRING;
            } else if (contentType == QIDENT_PARTITION) { 
                state = QIDENT;
            } else if (contentType == ANNOTATION_PARTITION) {
                level = 0; 
                restart = true;
                state = ANNOTATION;
            } else if (contentType == COMMENT_PARTITION) { 
                state = COMMENT;
            } else if (contentType == DEFINITION_PARTITION) {
                restart = true; 
            }
        }
        this.offset = (restart ? 0 : partitionOffset - offset);
        setRange(document, (restart ? partitionOffset : offset), length);
        saveOffset = this.offset;
        yybegin(state);
    }
    
    protected void reset(Reader r) {
        yyreset(r);
    }
    
    private void begin(int state) {
        saveOffset = yychar; 
        level = 0; 
        yybegin(state);
    }
    
    private IToken end(String type) {
        offset = saveOffset;
        yybegin(YYINITIAL);
        return new Token(type);
    }
    
    private IToken normalEnd() {
        yypushback(yylength());
        return end(NORMAL_PARTITION);
    }
    
	private IToken beginAnnotation() {
		level = 0;
		yybegin(ANNOTATION);
		offset = saveOffset;
		saveOffset = yychar + yylength();
		return new Token(NORMAL_PARTITION);
	}
%}

NONDIGIT = [a-zA-Z_]
DIGIT = [0-9]
S_CHAR = [^\"\\]
Q_CHAR = [^\'\\]
S_ESCAPE = "\\\'" | "\\\"" | "\\?" | "\\\\" | "\\a" | "\\b" | "\\f" | "\\n" | "\\r" | "\\t" | "\\v"

NL = \r|\n|\r\n
WS = ({NL} | [ \t\f])+
NormalID = {NONDIGIT} ({DIGIT}|{NONDIGIT})*
ID = {NormalID} | {QIdent}
Class = "block" | "class" | "connector" | "function" | "model" | "package" | "record" | "type"

CommentCont = ([^*]* | "*" [^/])* 
QIdentCont = ({Q_CHAR}|{S_ESCAPE})*
StringCont = ({S_CHAR}|{S_ESCAPE})*

QIdent = "\'" {QIdentCont} "\'"
String = "\"" {StringCont} "\""
Comment = "/*" {CommentCont} "*"? "*/"
Definition = {Class} {WS} {ID}

Other = .|{NL}

%state ANNOTATION, NORMAL, STRING, QIDENT, COMMENT

%%

<YYINITIAL> {
  "\""				{ /* YYINITIAL: "\"" */ begin(STRING); }
  "\'"				{ /* YYINITIAL: "\'" */ begin(QIDENT); }
  "/*"				{ /* YYINITIAL: "/*" */ begin(COMMENT); }
  "annotation"		{ /* YYINITIAL: "annotation" */ saveOffset = yychar; return beginAnnotation(); }
  ^{Definition}		{ /* YYINITIAL: Definition */ offset = yychar; return new Token(DEFINITION_PARTITION); }
  {WS}{Definition}	{ /* YYINITIAL: Definition */ offset = yychar; return new Token(DEFINITION_PARTITION); }
  {WS}				{ /* YYINITIAL: WS */ }
  {Other}			{ /* YYINITIAL: Other */ begin(NORMAL); }
  <<EOF>>			{ /* YYINITIAL: EOF */ offset = yychar; return Token.EOF; }
}

<NORMAL> {
  "\""				{ /* NORMAL: StringML */ return normalEnd(); }
  "\'"				{ /* NORMAL: QIdentML */ return normalEnd(); }
  "/*"				{ /* NORMAL: CommentML */ return normalEnd(); }
  {WS}{Definition}	{ /* NORMAL: Definition */ return normalEnd(); }
  "annotation"		{ /* NORMAL: "annotation" */ return beginAnnotation(); }
  {Other}			{ /* NORMAL: Other */ }
  <<EOF>>			{ /* NORMAL: EOF */ return normalEnd(); }
}

<ANNOTATION> {
  {String}			{ /* ANNOTATION: String */ }
  {QIdent}			{ /* ANNOTATION: QIdent */ }
  {Comment}			{ /* ANNOTATION: Comment */ }
  "("				{ /* ANNOTATION: "(" */ level++; }
  ")" 				{ /* ANNOTATION: ")" */ if (--level == 0) return end(ANNOTATION_PARTITION); }
  {Other}			{ /* ANNOTATION: Other */ }
  <<EOF>>			{ /* ANNOTATION: EOF */ return end(ANNOTATION_PARTITION); }
}

<STRING> {
  {StringCont}		{ /* STRING: StringCont */ }
  "\""				{ /* STRING: StringEnd */ return end(STRING_PARTITION); }
  <<EOF>>			{ /* STRING: EOF */ return end(STRING_PARTITION); }
}

<QIDENT> {
  {QIdentCont}		{ /* QIDENT: QIdentCont */ }
  "\'"				{ /* QIDENT: QIdentEnd */ yybegin(YYINITIAL); return end(QIDENT_PARTITION); }
  <<EOF>>			{ /* QIDENT: EOF */ return end(QIDENT_PARTITION); }
}

<COMMENT> {
  {CommentCont}		{ /* COMMENT: CommentCont */ }
  "*/"				{ /* COMMENT: (end of comment) */ return end(COMMENT_PARTITION); }
  <<EOF>>			{ /* COMMENT: EOF */ return end(COMMENT_PARTITION); }
}
