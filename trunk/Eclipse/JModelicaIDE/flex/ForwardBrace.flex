package org.jmodelica.ide.scanners.generated;

import java.io.StringReader;
import java.io.Reader;
import org.jmodelica.ide.helpers.DocumentReader;
import org.jmodelica.ide.scanners.BraceScanner;

%%

%public
%final
%class ForwardBraceScanner
%extends BraceScanner
%unicode
%buffer 256
%type Result
%char
%table

%{
    public ForwardBraceScanner() {
        this(new StringReader(""));
    }

    protected int getLength() {
    	return yychar + yylength();
    }

    protected int getOffset() {
    	return start;
    }
    
    protected void reset(Reader reader) {
        yyreset(reader);
    }

	protected DocumentReader createReader() {
        return new DocumentReader();
    }
%}

String = "\"" ( [^\"\\] | "\\" . )* "\""
QIdent = "\'"( [^\'\\] | "\\" . )* "\'"
Comment = ("/*" ~"*/") | ("//" ~(\n|\r|\n\r))
Other = [^{}()/\"\'\[\]]+
NotComment = "/" [^*/]

%%

"{"				{ addBrace(Brace.CURLY); }
"["				{ addBrace(Brace.BRACK); }
"("				{ addBrace(Brace.PAREN); }
"}"				{ Result res = removeBrace(Brace.CURLY); if (res != Result.NONE) return res; }
"]"				{ Result res = removeBrace(Brace.BRACK); if (res != Result.NONE) return res; }
")"				{ Result res = removeBrace(Brace.PAREN); if (res != Result.NONE) return res; }

{String}		{ }
{QIdent}		{ }
{Comment}		{ }
{Other}			{ }

{NotComment}	{ yypushback(1); }

<<EOF>>			{ return Result.EOF; }