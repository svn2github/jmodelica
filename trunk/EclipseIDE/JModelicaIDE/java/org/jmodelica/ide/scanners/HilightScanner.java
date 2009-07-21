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
package org.jmodelica.ide.scanners;

import org.eclipse.jface.text.TextAttribute;
import org.eclipse.jface.text.rules.ITokenScanner;
import org.eclipse.jface.text.rules.Token;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.widgets.Display;

public abstract class HilightScanner extends DocumentScanner implements ITokenScanner {
	protected static final Token NORMAL;
	protected static final Token KEYWORD;
	protected static final Token COMMENT;
	protected static final Token COMMENT_BOUNDARY; //asdkfljasd
	protected static final Token STRING;
	protected static final Token DEFINITION;
	protected static final Token QIDENT_BOUNDARY;
	protected static final Token STRING_BOUNDARY;
	
	protected static final Token ANNOTATION_NORMAL;
	protected static final Token ANNOTATION_KEYWORD;
	protected static final Token ANNOTATION_LHS;
	protected static final Token ANNOTATION_RHS;
	protected static final Token ANNOTATION_OPERATOR;
	protected static final Token ANNOTATION_STRING;
	
	static {
	    RGB normalColor     = new RGB(  0,   0,   0); 
	    RGB keywordColor    = new RGB(127,   0,  85);
	    RGB commentColor    = new RGB(150, 160, 230);
	    RGB stringColor     = new RGB(  0,  42, 255);
	    RGB annotation      = new RGB( 40,  70,  40);
	    RGB annotationKeywd = new RGB(127,  30,  85);
	    RGB annotationLhs   = new RGB(  0,  60,  50);
	    RGB annotationString= new RGB(  0, 120, 170);
		RGB annotationOperator
		                    = new RGB(170, 200, 170);
		RGB commentBoundary = new RGB(100, 110, 150);
		RGB qIdentBoundary  = new RGB(220,   0,   0); 
		RGB stringBoundary  = new RGB(  0,   0,  150);
		
        NORMAL     =  makeToken(normalColor);
        KEYWORD    =  makeToken(keywordColor, SWT.BOLD);
        COMMENT    =  makeToken(commentColor);
        COMMENT_BOUNDARY
                   =  makeToken(commentBoundary, SWT.BOLD);
        STRING     =  makeToken(stringColor);
        DEFINITION =  makeToken(normalColor);
        QIDENT_BOUNDARY =  makeToken(qIdentBoundary, SWT.BOLD);
        STRING_BOUNDARY =  makeToken(stringBoundary, SWT.BOLD);

        ANNOTATION_NORMAL  =  makeToken(annotation);   
        ANNOTATION_KEYWORD =  makeToken(annotationKeywd, SWT.BOLD);
        ANNOTATION_LHS     =  makeToken(annotationLhs);
        ANNOTATION_RHS     =  makeToken(annotationLhs, SWT.BOLD);
        ANNOTATION_OPERATOR=  makeToken(annotationOperator, SWT.BOLD);
        ANNOTATION_STRING  =  makeToken(annotationString);
	}

	private static Token makeToken(RGB fg) {
		return new Token(new TextAttribute(new Color(Display.getCurrent(), fg)));
	}

	private static Token makeToken(RGB fg, int style) {
		return new Token(new TextAttribute(new Color(Display.getCurrent(), fg), null, style));
	}
}