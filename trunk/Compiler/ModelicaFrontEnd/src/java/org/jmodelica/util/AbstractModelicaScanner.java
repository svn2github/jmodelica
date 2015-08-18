/*
    Copyright (C) 2015 Modelon AB

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
package org.jmodelica.util;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import org.jmodelica.util.formattedPrint.FormattingInfo;
import org.jmodelica.util.formattedPrint.FormattingItem;

public abstract class AbstractModelicaScanner extends beaver.Scanner {

	private static final int INITIAL_LINEBREAK_MAP_SIZE = 64;
	private int[] lineBreakMap;
	private FormattingInfo formattingInfo;
	private int maxLineBreakLine;

	public AbstractModelicaScanner() {
		reset();
	}

	public int[] getLineBreakMap() {
		if (lineBreakMap.length > maxLineBreakLine + 1)
			lineBreakMap = Arrays.copyOf(lineBreakMap, maxLineBreakLine + 1);
		return lineBreakMap;
	}

	private void reset() {
		lineBreakMap = new int[INITIAL_LINEBREAK_MAP_SIZE];
		maxLineBreakLine = 0;
		resetFormatting();
	}

	public void reset(java.io.Reader reader) {
		reset();
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
				addLineBreak(++line, matchOffset() + i + 1);
				++numberOfLineBreaksAdded;
			}
		}
		
		return numberOfLineBreaksAdded;
	}

	private void addLineBreak(int line, int offset) {
		if (lineBreakMap.length <= line) 
			lineBreakMap = Arrays.copyOf(lineBreakMap, 4 * lineBreakMap.length);
		lineBreakMap[line] = offset;
		if (line > maxLineBreakLine)
			maxLineBreakLine = line;
	}

	protected void addLineBreak() {
		addLineBreak(matchLine() + 1, matchOffset() + matchLength());
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
							line, startColumn, line, currentColumn - 1);
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
		int endColumn;
		if (numberOfLineBreaks > 0)
			endColumn = data.length() - Math.max(data.lastIndexOf('\n'), data.lastIndexOf('\r')) - 1;
		else
			endColumn = matchColumn() + matchLength();
		formattingInfo.addItem(type, data, matchLine() + 1, matchColumn() + 1, matchLine() + numberOfLineBreaks + 1, endColumn);
	}

	public FormattingInfo getFormattingInfo() {
		return formattingInfo;
	}

	protected abstract int matchLength();

	protected abstract int matchLine();
	
	protected abstract int matchColumn();

	protected abstract int matchOffset();

}
