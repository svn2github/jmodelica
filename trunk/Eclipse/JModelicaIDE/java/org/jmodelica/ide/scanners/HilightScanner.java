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
	protected static final Token STRING;
	protected static final Token DEFENITION;
	protected static final Token ANNOTATION_NORMAL;
	protected static final Token ANNOTATION_KEYWORD;
	protected static final Token ANNOTATION_COMMENT;
	protected static final Token ANNOTATION_STRING;
	
	static {
		RGB normalColor = new RGB(0x00, 0x00, 0x00);
		RGB keywordColor = new RGB(0x00, 0x00, 0xff);
		RGB commentColor = new RGB(0xc0, 0xc0, 0xc0);
		RGB stringColor = new RGB(0x00, 0xaa, 0x00);
		RGB annotationColor = new RGB(226, 254, 214);
		NORMAL = makeToken(normalColor);
		KEYWORD = makeToken(keywordColor);
		COMMENT = makeToken(commentColor);
		STRING = makeToken(stringColor, SWT.ITALIC);
		DEFENITION = makeToken(normalColor, SWT.BOLD);
		ANNOTATION_NORMAL = addBackground(NORMAL, annotationColor);
		ANNOTATION_KEYWORD = addBackground(KEYWORD, annotationColor);
		ANNOTATION_COMMENT = addBackground(COMMENT, annotationColor);
		ANNOTATION_STRING = addBackground(STRING, annotationColor);
	}

	private static Token makeToken(RGB fg) {
		return new Token(new TextAttribute(new Color(Display.getCurrent(), fg)));
	}

	private static Token addBackground(Token token, RGB bg) {
		TextAttribute attr = (TextAttribute) token.getData();
		Color bgCol = new Color(Display.getCurrent(), bg);
		return new Token(new TextAttribute(attr.getForeground(), bgCol, attr.getStyle()));
	}

	private static Token makeToken(RGB fg, int style) {
		return new Token(new TextAttribute(new Color(Display.getCurrent(), fg), null, style));
	}
}