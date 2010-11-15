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

public abstract class HilightScanner extends DocumentScanner implements ITokenScanner {
	protected static final Token NORMAL;
	protected static final Token KEYWORD;
	protected static final Token EXTRA_KEYWORD;
	protected static final Token BUILT_IN;
	protected static final Token DEPR_BUILT_IN;
	protected static final Token TYPE;
	protected static final Token OPERATOR;
	protected static final Token BOOLEAN;
	protected static final Token NUMBER;
	protected static final Token STRING;
	protected static final Token ID;
	protected static final Token QID;
	protected static final Token OPERATOR_DOT;
	protected static final Token COMMENT;
	protected static final Token COMMENT_BOUNDARY;
	protected static final Token Q_IDENT_BOUNDARY;
	protected static final Token STRING_BOUNDARY;

	protected static final Token ANNOTATION_NORMAL;
	protected static final Token ANNOTATION_KEYWORD;
	protected static final Token ANNOTATION_LHS;
	protected static final Token ANNOTATION_RHS;
	protected static final Token ANNOTATION_OPERATOR;
	protected static final Token ANNOTATION_STRING;

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
			return new Style(RGBfromString(parts[0]), RGBfromString(parts[1]),
					Integer.parseInt(parts[2]));
		}

		private static RGB RGBfromString(String s) {

			if (s.matches("\\s*null\\s*"))
				return null;

			String[] parts = s.split(",");
			return new RGB(Integer.parseInt(parts[0]),
					Integer.parseInt(parts[1]), Integer.parseInt(parts[2]));
		}
	}

	final static RGB annoBG = new RGB(226, 254, 214);
	final static Map<String, Style> colors = new HashMap<String, Style>();

	static {
		// TODO: Load preferences instead, and move this to preferences initialization
		colors.put("normal",              new Style(new RGB(0,   0,   0),   null,   SWT.NORMAL));
		colors.put("keyword",             new Style(new RGB(127, 0,   85),  null,   SWT.BOLD));
		colors.put("keyword.extra",       new Style(new RGB(127, 0,   85),  null,   SWT.BOLD));
		colors.put("builtin",             new Style(new RGB(0,   0,   0),   null,   SWT.ITALIC));
		colors.put("builtin.deprecated",  new Style(new RGB(0,   0,   0),   null,   SWT.ITALIC));
		colors.put("type",                new Style(new RGB(0,   0,   0),   null,   SWT.NORMAL));
		colors.put("operator",            new Style(new RGB(0,   0,   0),   null,   SWT.NORMAL));
		colors.put("boolean",             new Style(new RGB(30,  60,  200), null,   SWT.NORMAL));
		colors.put("number",              new Style(new RGB(30,  60,  200), null,   SWT.NORMAL));
		colors.put("string",              new Style(new RGB(30,  60,  200), null,   SWT.NORMAL));
		colors.put("ident",               new Style(new RGB(0,   0,   0),   null,   SWT.NORMAL));
		colors.put("qident",              new Style(new RGB(0,   0,   0),   null,   SWT.NORMAL));
		colors.put("operator.dot",        new Style(new RGB(0,   0,   0),   null,   SWT.NORMAL));
		colors.put("comment",             new Style(new RGB(150, 160, 230), null,   SWT.NORMAL));
		colors.put("comment.boundary",    new Style(new RGB(100, 110, 150), null,   SWT.BOLD));
		colors.put("qident.boundary",     new Style(new RGB(220, 0,   0),   null,   SWT.BOLD));
		colors.put("string.boundary",     new Style(new RGB(0,   0,   150), null,   SWT.BOLD));
		colors.put("annotation.normal",   new Style(new RGB(40,  70,  40),  annoBG, SWT.NORMAL));
		colors.put("annotation.keyword",  new Style(new RGB(127, 30,  85),  annoBG, SWT.BOLD));
		colors.put("annotation.lhs",      new Style(new RGB(0,   60,  50),  annoBG, SWT.NORMAL));
		colors.put("annotation.rhs",      new Style(new RGB(0,   60,  50),  annoBG, SWT.BOLD));
		colors.put("annotation.string",   new Style(new RGB(0,   120, 170), annoBG, SWT.NORMAL));
		colors.put("annotation.operator", new Style(new RGB(170, 200, 170), annoBG, SWT.BOLD));
			
		NORMAL              = getToken("normal");
		KEYWORD             = getToken("keyword");
		EXTRA_KEYWORD       = getToken("keyword.extra");
		BUILT_IN            = getToken("builtin");
		DEPR_BUILT_IN       = getToken("builtin.deprecated");
		TYPE                = getToken("type");
		OPERATOR            = getToken("operator");
		BOOLEAN             = getToken("boolean");
		NUMBER              = getToken("number");
		STRING              = getToken("string");
		ID                  = getToken("ident");
		QID                 = getToken("qident");
		OPERATOR_DOT        = getToken("operator.dot");
		COMMENT             = getToken("comment");
		ANNOTATION_NORMAL   = getToken("annotation.normal");
		ANNOTATION_KEYWORD  = getToken("annotation.keyword");
		ANNOTATION_LHS      = getToken("annotation.lhs");
		ANNOTATION_RHS      = getToken("annotation.rhs");
		ANNOTATION_STRING   = getToken("annotation.string");
		ANNOTATION_OPERATOR = getToken("annotation.operator");
		COMMENT_BOUNDARY    = getToken("comment.boundary");
		Q_IDENT_BOUNDARY    = getToken("qident.boundary");
		STRING_BOUNDARY     = getToken("string.boundary");
	}

	private static Token getToken(String key) {
		return makeToken(colors.get(key));
	}

	private static Color color(RGB rgb) {
		return rgb == null ? null : new Color(Display.getCurrent(), rgb);
	}

	private static Token makeToken(Style style) {
		return new Token(new TextAttribute(color(style.fg), color(style.bg),
				style.style));
	}

}