package org.jmodelica.util;

import java.util.HashMap;
import java.util.Map;

public abstract class AbstractModelicaScanner extends beaver.Scanner {

	private HashMap<Integer, Integer> lineBreakMap;
	private FormattingInfo formattingInfo;

	public AbstractModelicaScanner() {
		lineBreakMap = new HashMap<Integer, Integer>();
		lineBreakMap.put(0, 0);
		formattingInfo = new FormattingInfo();
	}

	public Map<Integer, Integer> getLineBreakMap() {
		return lineBreakMap;
	}

	public void reset(java.io.Reader reader) {
		lineBreakMap = new HashMap<Integer, Integer>();
		lineBreakMap.put(0, 0);
		formattingInfo = new FormattingInfo();
	}

	protected void addLineBreaks(String text) {
		int line = matchLine();
		for (int i = 0; i < text.length(); i += 1) {
			switch (text.charAt(i)) {
			case '\r':
				if (i < text.length() - 1 && text.charAt(i + 1) == '\n')
					++i;
			case '\n':
				lineBreakMap.put(++line, matchOffset() + i + 1);
			}
		}
	}

	protected void addLineBreak() {
		lineBreakMap.put(matchLine() + 1, matchOffset() + matchLength());
	}

	protected void addFormattingInformation(FormattingItem.Type type, String data, int startColumn) {
		formattingInfo.addItem(type, data, matchLine() + 1, startColumn + 1, matchLine() + 1, startColumn + matchLength());
	}

	public FormattingInfo getFormattingInfo() {
		return formattingInfo;
	}

	protected abstract int matchLength();

	protected abstract int matchLine();

	protected abstract int matchOffset();

}
