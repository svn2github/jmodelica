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
import org.jmodelica.ide.preferences.Preferences;
import org.jmodelica.ide.preferences.Preferences.NormalSyntaxColorPref;
import org.jmodelica.ide.preferences.Preferences.ReferenceSyntaxColorPref;
import org.jmodelica.ide.preferences.Preferences.DisabledSyntaxColorPref;
import org.jmodelica.ide.preferences.Preferences.SyntaxColorPref;

public abstract class HilightScanner extends DocumentScanner implements ITokenScanner {
	protected static Token NORMAL;
	protected static Token KEYWORD;
	protected static Token EXTRA_KEYWORD;
	protected static Token BUILT_IN;
	protected static Token DEPR_BUILT_IN;
	protected static Token TYPE;
	protected static Token OPERATOR;
	protected static Token BOOLEAN;
	protected static Token NUMBER;
	protected static Token STRING;
	protected static Token ID;
	protected static Token QID;
	protected static Token OPERATOR_DOT;
	protected static Token COMMENT;

	protected static Token ANNO_NORMAL;
	protected static Token ANNO_KEYWORD;
	protected static Token ANNO_EXTRA_KEYWORD;
	protected static Token ANNO_BUILT_IN;
	protected static Token ANNO_DEPR_BUILT_IN;
	protected static Token ANNO_TYPE;
	protected static Token ANNO_OPERATOR;
	protected static Token ANNO_BOOLEAN;
	protected static Token ANNO_NUMBER;
	protected static Token ANNO_STRING;
	protected static Token ANNO_ID;
	protected static Token ANNO_QID;
	protected static Token ANNO_OPERATOR_DOT;
	protected static Token ANNO_COMMENT;
	
	public static final RGB DEFAULT_ANNO_BG = new RGB(226, 254, 214);
	
	private static final int DEPR_STYLE = SWT.ITALIC | TextAttribute.STRIKETHROUGH;
	public static final SyntaxColorPref[] COLOR_DEFS = new SyntaxColorPref[] {
		new DisabledSyntaxColorPref("normal"),
		new DisabledSyntaxColorPref("type"),
		new DisabledSyntaxColorPref("operator"),
		new DisabledSyntaxColorPref("ident"),
		new NormalSyntaxColorPref("keyword",             new RGB(127, 0,   85),  null,   SWT.BOLD),
		new NormalSyntaxColorPref("builtin",             null,                   null,   SWT.ITALIC),
		new NormalSyntaxColorPref("builtin.depr",        null,                   null,   DEPR_STYLE),
		new NormalSyntaxColorPref("number",              new RGB(30,  60,  200), null,   SWT.NORMAL),
		new NormalSyntaxColorPref("comment",             new RGB(150, 160, 230), null,   SWT.NORMAL),
		new NormalSyntaxColorPref("anno.normal",         new RGB(40,  70,  40),  null, SWT.NORMAL, true),
		new NormalSyntaxColorPref("anno.operator",       new RGB(0,   0,   0),   null, SWT.NORMAL, true),
		new NormalSyntaxColorPref("anno.keyword",        new RGB(127, 30,  85),  null, SWT.BOLD,   true),
		new NormalSyntaxColorPref("anno.builtin",        null,                   null, SWT.ITALIC, true),
		new NormalSyntaxColorPref("anno.builtin.depr",   null,                   null, DEPR_STYLE, true),
		new NormalSyntaxColorPref("anno.number",         new RGB(30,  60,  200), null, SWT.NORMAL, true),
		new NormalSyntaxColorPref("anno.comment",        new RGB(150, 160, 230), null, SWT.NORMAL, true),
		new ReferenceSyntaxColorPref("keyword.extra",      "keyword"),
		new ReferenceSyntaxColorPref("qident",             "ident"),
		new ReferenceSyntaxColorPref("operator.dot",       "ident"),
		new ReferenceSyntaxColorPref("boolean",            "number"),
		new ReferenceSyntaxColorPref("string",             "number"),
		new ReferenceSyntaxColorPref("anno.keyword.extra", "anno.keyword", true),
		new ReferenceSyntaxColorPref("anno.type",          "anno.normal", true),
		new ReferenceSyntaxColorPref("anno.ident",         "anno.normal", true),
		new ReferenceSyntaxColorPref("anno.qident",        "anno.ident", true),
		new ReferenceSyntaxColorPref("anno.operator.dot",  "anno.ident", true),
		new ReferenceSyntaxColorPref("anno.boolean",       "anno.number", true),
		new ReferenceSyntaxColorPref("anno.string",        "anno.number", true),
	};

	public static void readColors() {
		NORMAL              = Preferences.getColorToken("normal");
		KEYWORD             = Preferences.getColorToken("keyword");
		EXTRA_KEYWORD       = Preferences.getColorToken("keyword.extra");
		BUILT_IN            = Preferences.getColorToken("builtin");
		DEPR_BUILT_IN       = Preferences.getColorToken("builtin.depr");
		TYPE                = Preferences.getColorToken("type");
		OPERATOR            = Preferences.getColorToken("operator");
		BOOLEAN             = Preferences.getColorToken("boolean");
		NUMBER              = Preferences.getColorToken("number");
		STRING              = Preferences.getColorToken("string");
		ID                  = Preferences.getColorToken("ident");
		QID                 = Preferences.getColorToken("qident");
		OPERATOR_DOT        = Preferences.getColorToken("operator.dot");
		COMMENT             = Preferences.getColorToken("comment");
		ANNO_COMMENT        = Preferences.getColorToken("anno.comment");
		ANNO_NORMAL         = Preferences.getColorToken("anno.normal");
		ANNO_KEYWORD        = Preferences.getColorToken("anno.keyword");
		ANNO_EXTRA_KEYWORD  = Preferences.getColorToken("anno.keyword.extra");
		ANNO_BUILT_IN       = Preferences.getColorToken("anno.builtin");
		ANNO_DEPR_BUILT_IN  = Preferences.getColorToken("anno.builtin.depr");
		ANNO_TYPE           = Preferences.getColorToken("anno.type");
		ANNO_OPERATOR       = Preferences.getColorToken("anno.operator");
		ANNO_BOOLEAN        = Preferences.getColorToken("anno.boolean");
		ANNO_NUMBER         = Preferences.getColorToken("anno.number");
		ANNO_STRING         = Preferences.getColorToken("anno.string");
		ANNO_ID             = Preferences.getColorToken("anno.ident");
		ANNO_QID            = Preferences.getColorToken("anno.qident");
		ANNO_OPERATOR_DOT   = Preferences.getColorToken("anno.operator.dot");
		ANNO_COMMENT        = Preferences.getColorToken("anno.comment");
	}

}