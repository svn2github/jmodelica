package org.jmodelica.ide.scanners.generated;

import java.io.Reader;
import java.io.StringReader;

import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.scanners.DocumentScanner;

%%

%public
%final
%class AnnotationNormalStateScanner
%extends DocumentScanner
%unicode
%buffer 1024
%int
%apiprivate
%char
%table

%{
    public AnnotationNormalStateScanner() {
        this(new StringReader(""));
    }
    
    public boolean isNormalState(IDocument doc, int start, int offset) {
        reset(doc, start, offset - start + 1);
        try {
            return yylex() != 0;
        } catch (java.io.IOException e) {
            return false;
        }
    }
    
    protected void reset(Reader r) {
        yyreset(r);
    }
%}

String = ( [^\"\\] | "\\" . )+
QIdent = ( [^\'\\] | "\\" . )+
Comment = ( [^*] | "*" [^/] )+
Other = [^/\"\']+
NotComment = "/" [^*/]

%state STRING, QIDENT, COMMENT, LINECOMMENT

%%

<YYINITIAL> {
  "\""				{ yybegin(STRING); }
  "\'"				{ yybegin(QIDENT); }
  "/*"				{ yybegin(COMMENT); }
  "//"				{ yybegin(LINECOMMENT); }
  {Other}			{ }
  <<EOF>>			{ return 1; }
  {NotComment}		{ yypushback(1); }
}

<STRING> {
  "\""				{ yybegin(YYINITIAL); }
  <<EOF>>			{ return 0; }
  {String}			{ }
}

<QIDENT> {
  "\'"				{ yybegin(YYINITIAL); }
  <<EOF>>			{ return 0; }
  {QIdent}			{ }
}

<COMMENT> {
  "*/"				{ yybegin(YYINITIAL); }
  <<EOF>>			{ return 0; }
  {Comment}			{ }
}

<LINECOMMENT> {
  (\n|\r|\n\r)		{ yybegin(YYINITIAL); }
  <<EOF>>			{ return 0; }
  [^\n\r]+			{ }
}