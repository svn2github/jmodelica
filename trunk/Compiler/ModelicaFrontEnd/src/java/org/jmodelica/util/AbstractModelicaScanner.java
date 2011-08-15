package org.jmodelica.util;

import java.util.HashMap;
import java.util.Map;

public abstract class AbstractModelicaScanner extends beaver.Scanner {

	private HashMap<Integer, Integer> lineBreakMap;

	public AbstractModelicaScanner() {
		lineBreakMap = new HashMap<Integer, Integer>();
		lineBreakMap.put(0, 0);
	}

	public Map<Integer, Integer> getLineBreakMap() {
		return lineBreakMap;
	}

	public void reset(java.io.Reader reader) {
		lineBreakMap = new HashMap<Integer, Integer>();
		lineBreakMap.put(0, 0);
	}

	protected void addLineBreaks(String text) {
		int line = yyline();
		for (int i = 0; i < text.length(); i += 1) {
			switch (text.charAt(i)) {
			case '\r':
				if (i < text.length() - 1 && text.charAt(i + 1) == '\n')
					++i;
			case '\n':
				lineBreakMap.put(++line, yychar() + i + 1);
			}
		}
	}

	protected void addLineBreak() {
		lineBreakMap.put(yyline() + 1, yychar() + yylength());
	}

	public abstract int yylength();

	public abstract int yyline();

	public abstract int yychar();

}
