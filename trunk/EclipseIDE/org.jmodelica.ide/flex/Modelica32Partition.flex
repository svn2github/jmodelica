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
import org.eclipse.jface.text.rules.IPartitionTokenScanner;
import org.eclipse.jface.text.rules.IToken;
import org.eclipse.jface.text.rules.Token;

import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.scanners.DocumentScanner;

%%

%public
%final
%class Modelica32PartitionScanner
%extends DocumentScanner
%implements IPartitionTokenScanner
%unicode
%function nextTokenInternal
%apiprivate
%type IToken
%char
%pack

%{
    private static final String PARTITION = IDEConstants.PLUGIN_ID + ".partition";
    public static final String NORMAL_PARTITION = PARTITION + ".normal";
    public static final String STRING_PARTITION = PARTITION + ".string";
    public static final String QIDENT_PARTITION = PARTITION + ".qident";
    public static final String ANNOTATION_PARTITION = PARTITION + ".annotation";
    public static final String COMMENT_PARTITION = PARTITION + ".comment";

    public static final String[] LEGAL_PARTITIONS = { 
        NORMAL_PARTITION, STRING_PARTITION, QIDENT_PARTITION, 
        ANNOTATION_PARTITION, COMMENT_PARTITION
    };
    
    private int offset;
    private int start;
    private int saveOffset;
    private int level;
    
    public Modelica32PartitionScanner() {
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
    
	private void beginAnnotation() {
		level = 0;
		yypushback(1);
		yybegin(ANNOTATION);
		saveOffset = yychar;
	}
%}

S_CHAR = [^\"\\]
Q_CHAR = [^'\\]
S_ESCAPE = "\\" {Other}

NL = \r|\n|\r\n
SingleWS = {NL} | [ \t\f]
WS = {SingleWS}+

CommentCont = ([^*]* | "*" [^/])* 
QIdentCont = ({Q_CHAR}|{S_ESCAPE})*
StringCont = ({S_CHAR}|{S_ESCAPE})*

QIdent = "\'" {QIdentCont} "\'"
String = "\"" {StringCont} "\""
Comment = "/*" ~"*/" | "//" .* {NL}
AnnotationStart = "annotation" {SingleWS}* "("

NormalEnd = "\"" | "'" | "/*" | "//" | {AnnotationStart}
Other = .|{NL}

%state ANNOTATION, NORMAL, STRING, QIDENT, COMMENT, LINE_COMMENT

%%

<YYINITIAL> {
  "\""				{ /* YYINITIAL: "\"" */         begin(STRING); }
  "\'"				{ /* YYINITIAL: "\'" */         begin(QIDENT); }
  "/*"				{ /* YYINITIAL: "/*" */         begin(COMMENT); }
  "//" 				{ /* YYINITIAL: "//" */         begin(LINE_COMMENT); }
  {AnnotationStart}	{ /* YYINITIAL: "annotation" */ beginAnnotation(); }
  {WS}				{ /* YYINITIAL: WS */           }
  {Other}			{ /* YYINITIAL: Other */        begin(NORMAL); }
  <<EOF>>			{ /* YYINITIAL: EOF */          offset = yychar; return Token.EOF; }
}

<NORMAL> {
  {NormalEnd}	    { /* NORMAL: NormalEnd */ return normalEnd(); }
  {Other}			{ /* NORMAL: Other */     }
  <<EOF>>			{ /* NORMAL: EOF */       return normalEnd(); }
}

<ANNOTATION> {
  {String}			{ /* ANNOTATION: String */  }
  {QIdent}			{ /* ANNOTATION: QIdent */  }
  {Comment}			{ /* ANNOTATION: Comment */ }
  "("				{ /* ANNOTATION: "(" */     level++; }
  ")" 				{ /* ANNOTATION: ")" */     if (--level == 0) return end(ANNOTATION_PARTITION); }
  {Other}			{ /* ANNOTATION: Other */   }
  <<EOF>>			{ /* ANNOTATION: EOF */     return end(ANNOTATION_PARTITION); }
}

<STRING> {
  "\""				{ /* STRING: StringEnd */  return end(STRING_PARTITION); }
  {StringCont}		{ /* STRING: StringCont */ }
  <<EOF>>			{ /* STRING: EOF */        return end(STRING_PARTITION); }
}

<QIDENT> {
  "'"				{ /* QIDENT: QIdentEnd */  return end(QIDENT_PARTITION); }
  {QIdentCont}		{ /* QIDENT: QIdentCont */ }
  <<EOF>>			{ /* QIDENT: EOF */        return end(QIDENT_PARTITION); }
}

<COMMENT> {
  "*/"				{ /* COMMENT: (end of comment) */ return end(COMMENT_PARTITION); }
  {CommentCont}		{ /* COMMENT: CommentCont */      }
  <<EOF>>			{ /* COMMENT: EOF */              return end(COMMENT_PARTITION); }
}


<LINE_COMMENT> {
	.* 				{ return end(COMMENT_PARTITION); }
	<<EOF>> 		{ return end(COMMENT_PARTITION); } 
}