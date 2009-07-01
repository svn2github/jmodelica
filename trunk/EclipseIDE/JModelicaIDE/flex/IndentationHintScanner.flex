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

import java.util.Stack;
import java.io.StringReader;
import java.io.IOException;

/**
 * Scanner which pushes indentation anchors, used to indent the 
 * source code. 
 *
 * @author philip
 */


%%

%public
%final
%class IndentationHintScanner
%unicode
%apiprivate
%type void
%char
%table

%{
    public IndentationHintScanner() {
        this(new StringReader(""));
    }
    
    public void analyze(String text) {
		
		yyreset(new StringReader(text));
		
		annotation_paren_level = 0;
		
		partial_newline = false;
		
		anchors = new BottomlessStack<Anchor>(Anchor.BOTTOM);
		
		sinks = new Stack<Sink>();
		
		last_state = YYINITIAL;
		
		
		try {
			yylex();
		} catch (IOException e) { }
		
	}
	
	/* scanner state variables */
	
	public BottomlessStack<Anchor> anchors;
	
	public Stack<Sink> sinks;
	
	int annotation_paren_level;
	
	boolean partial_newline;
	
	int last_state;
	
	
	public enum Indent { INDENT	    {public int modify(int indent, int tabWidth) { return indent + tabWidth; } },
						 SAME       {public int modify(int indent, int tabWidth) { return indent; } },
						 NONE       {public int modify(int indent, int tabWidth) { return 0; } },
						 COMMENT    {public int modify(int indent, int tabWidth) { return indent + 3; } };
						 public abstract int modify(int indent, int tabWidth);
					   } 
	/**
	 * Anchor point in text, providing indentation hints. 
	 * @author philip
	 */
	public static class Anchor {
		
		public final static Anchor BOTTOM = new Anchor(0, Indent.SAME, "#"); 
	
		public int offset;
		public Indent indent;
		public String id;
				
		public Anchor(int offset, Indent indent, String id) {
			this.offset = offset;
			this.indent = indent;
			this.id = id; 
		}
		public Anchor(int offset) { this(offset, null, null); }
	}
		
	/** 
	  * Sink tokens, used to "sink" lines containing 'end' and 'equation' etc
	  * to a reference Anchor 
	  * @author philip */
	public static class Sink {
		
		public final static Sink BOTTOM = new Sink(0, Anchor.BOTTOM);
	
		public int offset;
		public Anchor reference;
		public Sink(int offset, Anchor reference) { 
			this.reference = reference;
			this.offset = offset;
		}
	}
			
	public Anchor anchorAt(int offset) {
		Anchor result = Anchor.BOTTOM;
		for (Anchor a : anchors) {
			if (a.offset <= offset)
				result = a;
		}
		return result;
	}
	
	public Sink sinkAt(int lower, int upper) {
		Sink result = null;
		for (Sink sink : sinks) {
			if (lower <= sink.offset && sink.offset < upper)
				result = sink;
		}
		return result;	
	}	

	/**
 	* Stack with default "bottom" element, which can be popped indefinitely.
 	*
 	* @author philip
 	*/
	public static class BottomlessStack<E> extends Stack<E> {
		
		public BottomlessStack(E bottom) {
			super();
			super.push(bottom);
		}
		
		public E pop() {
			if (size() == 1)
				return super.peek();
			return super.pop();
		}
	}

	
	void pushAnchor(Indent indent, String id) {
		anchors.push(new Anchor(yychar, indent, id));
	}

	void pushAnchor(Indent indent) { 
		pushAnchor(indent, "#"); 
	}
	
	void popAnchor() {
		anchors.pop();
	}
	
	void popTo(String id) {
		while (anchors.peek() != Anchor.BOTTOM &&
			   !anchors.peek().id.matches(id)) {
			anchors.pop();
		}
	}
	
	void popPast(String id) {
		popTo(id); 
		anchors.pop();
	}
	
	void pushSink() {
		Anchor ref = Anchor.BOTTOM;
		for (Anchor a : anchors)
			if ("class".equals(a.id))
				ref = a;
		sinks.push(new Sink(yychar, ref));
	}

	void setLastIndent(Indent indent) {
		anchors.peek().indent = Indent.SAME;
	}
	
%}



IDCHAR = [a-zA-Z_]
DIGIT = [0-9]
Q_CHAR = [^\'\\]
S_ESCAPE = "\\\'" | "\\\"" | "\\?" | "\\\\" | "\\a" | "\\b" | "\\f" | "\\n" | "\\r" | "\\t" | "\\v"

NewLine = \r|\n|\r\n
NonNewLineWhiteSpace = [ \t\f]
WhiteSpace = ({NewLine} | {NonNewLineWhiteSpace})+
            
NormalId = {IDCHAR} ({DIGIT}|{IDCHAR})*
Id = {NormalId} | {QIdent}
QIdent = "\'"  {QIdentCont}*  "\'"

Class = "block" | "when" | "class" | "connector" | "function" | "model" | "package" | "record" | "type" | "for"
Separator = "equation" | "algorithm" | "public" | "protected"

End = "end"

QIdentCont = {Q_CHAR} | {S_ESCAPE}

Other = . | {NewLine}


%state LINEBEGIN, CLASS, END
%xstate COMMENT, COMMENT_LINEBEGIN, STRING, QIDENT, ANNOTATION, ANNOTATION_LINEBEGIN 

%%

 
  <<EOF>> 			{ return; }
  "/*"  			{ pushAnchor(Indent.COMMENT, "comment");    last_state = yystate(); yybegin(COMMENT_LINEBEGIN); }
  "\""				{ pushAnchor(Indent.NONE,    "string");     last_state = yystate(); yybegin(STRING); }
  "\'"				{ pushAnchor(Indent.NONE,    "qident");      yybegin(QIDENT); }
  "annotation"		{ pushAnchor(Indent.INDENT,  "annotation"); yybegin(ANNOTATION); }

<YYINITIAL> {
  {Class}			{ pushAnchor(Indent.INDENT, "class"); } 
  {Separator}		{ pushSink(); }
  {End}				{ pushSink(); pushAnchor(Indent.INDENT); yybegin(END); }
  {NewLine} 		{ yybegin(LINEBEGIN); } 
  ";"				{ popTo("newline|class");
  					  partial_newline = false; 
  					  if (!anchors.peek().id.equals("class"))
  					  		setLastIndent(Indent.SAME); }
} 

<LINEBEGIN> {
  {Separator}		{ pushSink(); }  				
  {Class} 			|
  {End}				|
  ";"				{ pushAnchor(Indent.SAME, "newline"); 
  					  yypushback(yytext().length()); 
  					  yybegin(YYINITIAL); }
  {Id}			    { pushAnchor(partial_newline ? Indent.SAME : Indent.INDENT, 
  								 partial_newline ? "#" : "newline");
  					  partial_newline = true;
  					  yybegin(YYINITIAL); }
  {WhiteSpace}*		{ }
}

<ANNOTATION_LINEBEGIN> {
	{WhiteSpace}	{ }
	. 				{ pushAnchor(Indent.SAME, "annotation_newline"); 
					  yypushback(1); yybegin(ANNOTATION); }
}

<ANNOTATION> {
  "("				{ annotation_paren_level++; }
  ")" 				{ if (--annotation_paren_level == 0) { 
  							popPast("annotation");
  							yybegin(YYINITIAL); 
  					  }
					} 
   "/*"  			{ pushAnchor(Indent.COMMENT, "comment"); last_state = yystate(); yybegin(COMMENT_LINEBEGIN); }
  "\""				{ pushAnchor(Indent.NONE,    "string");  last_state = yystate(); yybegin(STRING); }
  {NewLine} 	    { pushAnchor(Indent.SAME); yybegin(ANNOTATION_LINEBEGIN); }
  {Other}			{ 	}
}

<END> {
  {WhiteSpace}		{  }
  {Id}			    {  }
  {Other}			{ popPast("class"); yybegin(YYINITIAL); }
}

<STRING> {
  "\""				{ popPast("string"); yybegin(last_state); }
  {Other}			{ }
}

<QIDENT> {
  "\'"				{ popPast("qident"); yybegin(YYINITIAL); }
  {Other}			{ }
}

<COMMENT_LINEBEGIN> {
  {WhiteSpace} 		{ }
  "*/"				{ popPast("comment"); yybegin(last_state); }
  {Other}		    { pushAnchor(Indent.SAME); yybegin(COMMENT); }
}

<COMMENT> {
  "*/"				{ popPast("comment"); yybegin(last_state); }
  {NewLine}	     	{ yybegin(COMMENT_LINEBEGIN); }
  {Other}			{ }
}

/* fallthrough */
{Other}				{ yybegin(YYINITIAL); }