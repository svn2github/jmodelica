package org.jmodelica.util;

import java.util.HashMap;
import java.util.Map;

public abstract class AbstractModelicaScanner extends beaver.Scanner {

	private HashMap<Integer, Integer> lineBreakMap;
	protected FormattingInfo formattingInfo;

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
		resetFormatting();
	}
	
	public void resetFormatting() {
		formattingInfo = new FormattingInfo();
	}

	protected int addLineBreaks(String text) {
		int numberOfLineBreaksAdded = 0;
		int line = matchLine();
		for (int i = 0; i < text.length(); i += 1) {
			switch (text.charAt(i)) {
			case '\r':
				if (i < text.length() - 1 && text.charAt(i + 1) == '\n')
					++i;
			case '\n':
				lineBreakMap.put(++line, matchOffset() + i + 1);
				++numberOfLineBreaksAdded;
			}
		}
		
		return numberOfLineBreaksAdded;
	}

	protected void addLineBreak() {
		lineBreakMap.put(matchLine() + 1, matchOffset() + matchLength());
	}
	
	protected void addWhiteSpaces(String data) {
		int line = matchLine() + 1;
		int currentColumn = matchColumn() + 1;
		int startColumn = 0;
		StringBuilder currentSpaces = new StringBuilder();
		for (int i = 0; i < data.length(); i++) {
			char currentCharacter = data.charAt(i);
			switch (currentCharacter) {
			case '\r':
				++line;
				startColumn = currentColumn;
				currentSpaces.append('\r');
				if (i + 1 < data.length() && data.charAt(i + 1) == '\n') {
					currentSpaces.append('\n');
					++i;
				}
				formattingInfo.addItem(FormattingItem.Type.LINE_BREAK, currentSpaces.toString(), line, startColumn,
						line, startColumn + currentSpaces.length() - 1);
				currentSpaces = new StringBuilder();
				++line;
				currentColumn = 0;
				break;
			case '\n':
				startColumn = currentColumn;
				formattingInfo.addItem(FormattingItem.Type.LINE_BREAK, "\n", line, startColumn,
						line, startColumn);
				currentSpaces = new StringBuilder();
				++line;
				currentColumn = 0;
				break;
			case ' ':
			case '\t':
			case '\f':
				if (currentSpaces.length() == 0) {
					startColumn = currentColumn;
				}
				currentSpaces.append(data.charAt(i));
				if (i + 1 < data.length() && (data.charAt(i + 1) == '\r' || data.charAt(i + 1) == '\n')) {
					formattingInfo.addItem(FormattingItem.Type.NON_BREAKING_WHITESPACE, currentSpaces.toString(),
							line, startColumn, line, currentColumn);
					currentSpaces = new StringBuilder();
				}
				break;
			default:
				if (currentSpaces.length() > 0) {
					formattingInfo.addItem(FormattingItem.Type.NON_BREAKING_WHITESPACE, currentSpaces.toString(),
							line, startColumn, line, currentColumn);
					currentSpaces = new StringBuilder();
				}
				break;
			}

			++currentColumn;
		}
		
		if (currentSpaces.length() > 0) {
			formattingInfo.addItem(FormattingItem.Type.NON_BREAKING_WHITESPACE, currentSpaces.toString(), line,
					startColumn, line, currentColumn - 1);
		}
	}
	
	protected void addFormattingInformation(FormattingItem.Type type, String data) {
		addFormattingInformation(type, data, 0);
	}

	protected void addFormattingInformation(FormattingItem.Type type, String data, int numberOfLineBreaks) {
		formattingInfo.addItem(type, data, matchLine() + 1, matchColumn() + 1, matchLine() + numberOfLineBreaks + 1,
				matchColumn() + matchLength());
	}

	public FormattingInfo getFormattingInfo() {
		return formattingInfo;
	}

	protected abstract int matchLength();

	protected abstract int matchLine();
	
	protected abstract int matchColumn();

	protected abstract int matchOffset();

}
