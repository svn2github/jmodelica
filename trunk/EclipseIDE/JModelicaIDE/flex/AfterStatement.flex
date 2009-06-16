package org.jmodelica.ide.scanners.generated;

import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;

import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.helpers.BackwardsDocumentReader;
import org.jmodelica.ide.helpers.DocumentReader;
import org.jmodelica.ide.scanners.DocumentScanner;

%%

%public
%final
%class AfterStatementScanner
%extends DocumentScanner
%unicode
%buffer 256
%apiprivate
%int
%char
%table

%{
    public AfterStatementScanner() {
        this(new StringReader(""));
    }
    
    public boolean isAfterStatement(IDocument document, int offset) {
        reset(document, offset);
        try {
			return yylex() != 0;
		} catch (IOException e) {
			return true;
		}
    }
    
    protected void reset(Reader r) {
        yyreset(r);
    }
    
    protected DocumentReader createReader() {
        return new BackwardsDocumentReader();
    }
%}

Comment = ("/*" ~"*/") | ([^\n\r]* "//")
WhiteSpace = [ \t\n\r]+

%%

{WhiteSpace}	{ }
{Comment}		{ }
";"				{ return 1; }
.				{ return 0; }
<<EOF>>			{ return 1; }