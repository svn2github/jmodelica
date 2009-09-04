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

import java.io.IOException;
import java.util.*;
import java.io.Reader;
import java.io.StringReader;

import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.helpers.DocumentReader;
import org.jmodelica.ide.helpers.BackwardsDocumentReader;
import org.jmodelica.ide.scanners.DocumentScanner;

%%

%public
%final
%class BackwardClassFinder
%extends DocumentScanner
%unicode
%apiprivate
%buffer 1024
%int
%char
%table

%{
    private String target;
    private String last;
    private int count;
    
    public BackwardClassFinder() {
        this(new StringReader(""));
    }
    
    public int findIndent(IDocument document, int offset, String id) {
        
        yyreset(new BackwardsDocumentReader(document, offset));
        
        target = id;
        if (target != null)
            target = new StringBuilder(target).reverse().toString();
		
		count = target == null ? 1 : 0;
	
        try {
			return yylex();
		} catch (IOException e) {
			return -1;
		}
    }
 	
	public void reset(Reader reader) {
		reset(reader);
	}       

%}

NONDIGIT = [a-zA-Z_]
DIGIT = [0-9]
NormId = ({DIGIT}|{NONDIGIT})* {NONDIGIT}
QIdent = "\'" ( [^\'\\] | . "\\" )* "\'"
String = "\"" ( [^\"\\] | . "\\" )* "\""
Comment = ("/*" ~"*/") | ([^\n\r]* "//")

WhiteSpace = [ \t\r\n]+
Id = {NormId} | {QIdent}

Class = "kcolb" | "ssalc" | "rotcennoc" | "noitcnuf" | "ledom" | "egakcap" | "drocer" | "epyt"
End = "dne"

%%
  {Class} { 
	  if (target == null || target.equals(last) ) {
	  	  count--;
	  	  if (count <= 0) {
			  return yychar; 
	  	  }
	  }
  }	
  {End} { 
  	  if (target == null || target.equals(last)) {   
  		++count;
      }
  }

  {Id}			{   last = yytext(); }

  {String}		{ }
  {Comment}		{ }
  {WhiteSpace}  { }
  .|\n			{ }

  <<EOF>>		{ return -1; }

