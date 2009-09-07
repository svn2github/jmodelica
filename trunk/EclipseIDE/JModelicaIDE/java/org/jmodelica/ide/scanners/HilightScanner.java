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

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import org.eclipse.jface.text.TextAttribute;
import org.eclipse.jface.text.rules.ITokenScanner;
import org.eclipse.jface.text.rules.Token;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.widgets.Display;


public abstract class HilightScanner extends DocumentScanner implements
        ITokenScanner {
protected static final Token NORMAL;
protected static final Token KEYWORD;
protected static final Token COMMENT;
protected static final Token COMMENT_BOUNDARY;
protected static final Token STRING;
protected static final Token DEFINITION;
protected static final Token Q_IDENT_BOUNDARY;
protected static final Token STRING_BOUNDARY;

protected static final Token ANNOTATION_NORMAL;
protected static final Token ANNOTATION_KEYWORD;
protected static final Token ANNOTATION_LHS;
protected static final Token ANNOTATION_RHS;
protected static final Token ANNOTATION_OPERATOR;
protected static final Token ANNOTATION_STRING;
private static final String CONFIG_FILENAME = ".modelicacolors";

static class Style {

public RGB fg, bg;
public int style;

public Style(RGB fgi, RGB bgi, int stylei) {
    fg = fgi == null ? new RGB(0, 0, 0) : fgi;
    bg = bgi;
    style = stylei;
}
public String toString() {
    return (fg + "@" + bg + "@" + style).replaceAll("[^0-9a-z@,]", "");
}

public static Style fromString(String string) {
    String[] parts = string.split("@");
    return new Style(
        RGBfromString(parts[0]),
        RGBfromString(parts[1]),
        Integer.parseInt(parts[2]));
}

private static RGB RGBfromString(String s) {

    if(s.matches("\\s*null\\s*")) 
        return null;

    String[] parts = s.split(",");
    return new RGB(
        Integer.parseInt(parts[0]),
        Integer.parseInt(parts[1]),
        Integer.parseInt(parts[2]));
}
}

final static RGB defaultAnnotationBG = new RGB(226, 254, 214);
final static Map<String, Style> colors = new HashMap<String, Style>() {{
    
    put("normal",             new Style(new RGB(  0, 0,   0),   null,                SWT.NORMAL)); 
    put("keyword",            new Style(new RGB(127, 0,   85),  null,                SWT.BOLD));
    put("comment",            new Style(new RGB(150, 160, 230), null,                SWT.NORMAL));
    put("string",             new Style(new RGB( 30, 60,  200), null,                SWT.NORMAL));
    put("annotationNormal",   new Style(new RGB( 40, 70,  40),  defaultAnnotationBG, SWT.NORMAL));
    put("annotationKeyword",  new Style(new RGB(127, 30,  85),  defaultAnnotationBG, SWT.BOLD));
    put("annotationLHS",      new Style(new RGB(  0, 60,  50),  defaultAnnotationBG, SWT.NORMAL));
    put("annotationRHS",      new Style(new RGB(  0, 60,  50),  defaultAnnotationBG, SWT.BOLD));
    put("annotationString",   new Style(new RGB(  0, 120, 170), defaultAnnotationBG, SWT.NORMAL));
    put("annotationOperator", new Style(new RGB(170, 200, 170), defaultAnnotationBG, SWT.BOLD));
    put("commentBoundary",    new Style(new RGB(100, 110, 150), null,                SWT.BOLD));
    put("qIdentBoundary",     new Style(new RGB(220, 0,   0),   null,                SWT.BOLD)); 
    put("stringBoundary",     new Style(new RGB(  0, 0,   150), null,                SWT.BOLD));
    
}};

static {
    
    try {
        File file = new File(CONFIG_FILENAME);
        if (!file.exists()) {
            file.createNewFile();
            FileOutputStream fout = new FileOutputStream(file);
            new Properties().store(fout, 
                       " syntax: name=r,g,b@r,g,b@style\n" +
                       "# where values for style are 0:Normal, 1:Bold, 2:Italic, 3:Bold Italic\n" +
                       "\n" +
                       "# example: keyword=127,0,85@null@1\n" +
            		   "\n" +
            		   "# possible values for name are:\n" +
            		   "# normal, keyword, comment, string, annotationNormal, annotationKeyword,\n"+
            		   "# annotationLHS, annotationRHS, annotationString, annotationOperator,\n"+
            		   "# commentBoundary, qIdentBoundary, stringBoundary\n");
            fout.close();
        } else {
            FileInputStream fin = new FileInputStream(file);
            Properties p = new Properties();
            p.load(fin);
            fin.close();
            for (Object o : p.keySet()) 
                colors.put((String)o, Style.fromString((String)(p.get(o))));
        }
        
    } catch (Exception e) {}  
    
	NORMAL              = makeToken(colors.get("normal"));
	DEFINITION          = makeToken(colors.get("normal"));
	KEYWORD             = makeToken(colors.get("keyword"));
	COMMENT             = makeToken(colors.get("comment"));
	STRING              = makeToken(colors.get("string"));
	ANNOTATION_NORMAL   = makeToken(colors.get("annotationNormal"));
	ANNOTATION_KEYWORD  = makeToken(colors.get("annotationKeyword"));
	ANNOTATION_LHS      = makeToken(colors.get("annotationLHS"));
	ANNOTATION_RHS      = makeToken(colors.get("annotationRHS"));
	ANNOTATION_STRING   = makeToken(colors.get("annotationString"));
	ANNOTATION_OPERATOR = makeToken(colors.get("annotationOperator"));
	COMMENT_BOUNDARY    = makeToken(colors.get("commentBoundary"));
	Q_IDENT_BOUNDARY    = makeToken(colors.get("qIdentBoundary"));
	STRING_BOUNDARY     = makeToken(colors.get("stringBoundary"));
}

private static Color color(RGB rgb) { 
    return rgb == null ? null : new Color(Display.getCurrent(), rgb);
}

private static Token makeToken(Style style) {
    return new Token(new TextAttribute(color(style.fg), color(style.bg), style.style));
}
	
}