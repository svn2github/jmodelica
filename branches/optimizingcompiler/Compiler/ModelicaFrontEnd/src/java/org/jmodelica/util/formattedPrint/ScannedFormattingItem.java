package org.jmodelica.util.formattedPrint;

import beaver.Symbol;

/**
 * An object that holds the value and position of some sort of formatting. It can, for example, hold the position,
 * extent and actual string representation of a comment or white spaces forming indentation.
 */
public class ScannedFormattingItem extends FormattingItem implements Comparable<ScannedFormattingItem> {
	
	private static ScannedFormattingItem compareItem = new ScannedFormattingItem(Type.DEFAULT, "", 0, 0, 0, 0);
	
	protected static ScannedFormattingItem getStartCompareItem(Symbol forNode) {
		return getCompareItem(Symbol.getLine(forNode.getStart()), Symbol.getColumn(forNode.getStart()));
	}
	
	protected static ScannedFormattingItem getEndCompareItem(Symbol forNode) {
		return getCompareItem(Symbol.getLine(forNode.getEnd()), Symbol.getColumn(forNode.getEnd()));
	}
	
	protected static ScannedFormattingItem getCompareItem(int line, int col) {
		compareItem.startLine = compareItem.endLine = line;
		compareItem.startColumn = compareItem.endColumn = col;
		return compareItem;
	}
	
	protected int startLine;
	protected int startColumn;
	protected int endLine;
	protected int endColumn;

	/**
	 * Creates a <code>ScannedFormattingItem</code>.
	 * @param type the type of this item.
	 * @param data the string representation of what this item holds, such as an actual comment.
	 * @param startLine the line in the source code at which this item begins.
	 * @param startColumn the column in the source code at which this item begins.
	 * @param endLine the line in the source code at which this item ends. 
	 * @param endColumn the column in the source code at which this item ends.
	 */
	public ScannedFormattingItem(Type type, String data, int startLine, int startColumn,
			int endLine, int endColumn) {
		super(type, data);
		this.startLine = startLine;
		this.startColumn = startColumn;
		this.endLine = endLine;
		this.endColumn = endColumn;
	}
	
	/**
	 * Gets the line number of where the start of this symbol was found when it was scanned.
	 * @return the line at which this symbol started when it was scanned.
	 */
	public int getStartLine() {
		return startLine;
	}
	
	/**
	 * Gets the column number of where the start of this symbol was found when it was scanned.
	 * @return the column at which this symbol started when it was scanned.
	 */
	public int getStartColumn() {
		return startColumn;
	}
	
	/**
	 * Gets the line number of where the end of this symbol was found when it was scanned.
	 * @return the line at which this symbol ended when it was scanned.
	 */
	public int getEndLine() {
		return endLine;
	}
	
	/**
	 * Gets the column number of where the end of this symbol was found when it was scanned.
	 * @return the column at which this symbol ended when it was scanned.
	 */
	public int getEndColumn() {
		return endColumn;
	}
	
	@Override
	public Adjacency getAdjacency(FormattingItem otherItem) {
		if (!otherItem.isScanned()) {
			return Adjacency.NONE;
		}
		ScannedFormattingItem otherScannedItem = (ScannedFormattingItem) otherItem;

		if ((startLine == otherScannedItem.endLine && startColumn == otherScannedItem.endColumn + 1) ||
				(otherScannedItem.endsWithLineBreak() && startLine == otherScannedItem.endLine + 1 && startColumn == 1)) {
			return Adjacency.FRONT;
		} else if (endLine == otherScannedItem.startLine && endColumn + 1 == otherScannedItem.startColumn ||
				(this.endsWithLineBreak() && endLine + 1 == otherScannedItem.startLine && otherScannedItem.startColumn == 1)) {
			return Adjacency.BACK;
		}

		return Adjacency.NONE;
	}
	
	protected boolean endsWithLineBreak() {
		return (type == Type.LINE_BREAK || (type == Type.COMMENT && (data.endsWith("\r") || data.endsWith("\n"))));
	}

	@Override
	public RelativePosition getFrontRelativePosition(int line, int column) {
		if ((endLine == line && endColumn + 1 == column) || (column == 1 && endLine + 1 == line && endsWithLineBreak()))
			return RelativePosition.FRONT_ADJACENT;
		else if (endLine < line || (endLine == line && endColumn < column))
			return RelativePosition.BEFORE;
		else if (startLine > line || (startLine == line && startColumn > column))
			return RelativePosition.AFTER;
		else
			return RelativePosition.INSIDE;
	}
	
	@Override
	public RelativePosition getBackRelativePosition(int line, int column) {
		if (startLine == line && startColumn - 1 == column)
			return RelativePosition.BACK_ADJACENT;
		else if (startLine < line || (startLine == line && startColumn < column))
			return RelativePosition.BEFORE;
		else if (startLine > line || (startLine == line && startColumn > column))
			return RelativePosition.AFTER;
		else
			return RelativePosition.INSIDE;
	}
	
	@Override
	public ScannedFormattingItem mergeItems(Adjacency where, FormattingItem otherItem) {
		if (where == Adjacency.NONE || otherItem.type == Type.EMPTY) {
			return this;
		}
		
		MixedFormattingItem mergedItems = new MixedFormattingItem(this);
		return mergedItems.mergeItems(where, otherItem);
	}

	ScannedFormattingItem[] splitAfterFirstLineBreak() {
		ScannedFormattingItem[] result = new ScannedFormattingItem[1];
		result[0] = this;
		return result;
	}

	/**
	 * Gets information about this <code>ScannedFormattingItem</code> in an XML styled text string, which might be
	 * usable when debugging.
	 * @param printData if true, the method also prints the data of the item, otherwise the tag is short hand
	 * closed.
	 * @return a String with information about this item's type, starting position, ending position and if
	 * <code>printData</code> is true also the actual string data this formatting item holds.
	 */
	public String getInformationString(boolean printData) {
		StringBuilder stringBuilder = new StringBuilder("<formattingitem type=\"" + type +
				"\" startline=\"" + startLine +
				"\" startcolumn=\"" + startColumn +
				"\" endline=\"" + endLine +
				"\" endcolumn=\"" + endColumn +
				"\"");

		if (printData) {
			stringBuilder.append(">" + toString() + "</formattingitem>");
		} else {
			stringBuilder.append(" />");
		}

		return stringBuilder.toString();
	}
	
	/**
	 * Gets information about this <code>ScannedFormattingItem</code> in an XML styled text string, which might be
	 * usable when debugging. Identical to calling getInformationString(false).
	 * @return a String with information about this item's type, starting position and ending position.
	 */
	public String getInformationString() {
		return getInformationString(false);
	}

	/**
	 * Compares this scanned formatting item with another one to determine which item appeared first when scanned,
	 * and if both items started at the same position, then which one ended first. If this item appeared first (or
	 * if both items started at the same position, but this item ended first), then a negative value is returned.
	 * If this item started after the other item (or if both items started at the same position, but this item
	 * ended last), then a positive value is returned. Otherwise 0 is returned.
	 * @return a negative value if this item started first (or if both items started at the same position, but this
	 * item ended first). A positive value if this item started after the other item (or if both items started at
	 * the same position, but this item ended last). Otherwise, the value 0.
	 */
	public int compareTo(ScannedFormattingItem otherItem) {
		int result = this.getStartLine() - otherItem.getStartLine();
		if (result == 0) {
			result = this.getStartColumn() - otherItem.getStartColumn();
			if (result == 0) {
				result = this.getEndLine() - otherItem.getEndLine();
				if (result == 0) {
					result = this.getEndColumn() - otherItem.getEndColumn();
				}
			}
		}
		return result;
	}

	public boolean equals(Object otherObject) {
		if (otherObject instanceof ScannedFormattingItem) {
			return (this.compareTo((ScannedFormattingItem) otherObject) == 0);
		}

		return false;
	}
	
	@Override
	public DefaultFormattingItem copyWhitepacesFromFormatting() {
		if (type == FormattingItem.Type.NON_BREAKING_WHITESPACE || type == FormattingItem.Type.LINE_BREAK) {
			return new DefaultFormattingItem(data);
		}
		
		return new EmptyFormattingItem();
	}

	/**
	 * Checks whether <code>line</code> and <code>column</code> are equal to this
	 * <code>ScannedFormattingItem</code>'s starting position.
	 * @param line the line for which to determine if its equal to this item's starting position.
	 * @param column the column for which to determine if its equal to this item's starting position.
	 * @return true if <code>line</code> and <code>column</code> are equal to this
	 * <code>ScannedFormattingItem</code>'s starting position. Otherwise false.
	 */
	public boolean atStart(int line, int column) {
		return (getStartLine() == line && getStartColumn() == column);
	}

	/**
	 * Checks whether <code>line</code> and <code>column</code> are equal to this
	 * <code>ScannedFormattingItem</code>'s ending position.
	 * @param line the line for which to determine if its equal to this item's ending position.
	 * @param column the column for which to determine if its equal to this item's ending position.
	 * @return true if <code>line</code> and <code>column</code> are equal to this
	 * <code>ScannedFormattingItem</code>'s ending position. Otherwise false.
	 */
	public boolean atEnd(int line, int column) {
		return (getEndLine() == line && getEndColumn() == column);
	}
	
	@Override
	public final boolean isScanned() {
		return true;
	}
	
	@Override
	public boolean isScannedMixed() {
		return false;
	}
	
	@Override
	public final boolean isEmptyDefault() {
		return false;
	}
}
