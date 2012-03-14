package org.jmodelica.util;

/**
 * An object that holds the value and position of some sort of formatting. It can, for example, hold the position,
 * extent and actual string representation of a comment or white spaces forming indentation.
 */
public class ScannedFormattingItem extends FormattingItem {
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
	
	@Override
	public Adjacency getAdjacency(FormattingItem otherItem) {
		if (!(otherItem instanceof ScannedFormattingItem)) {
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
		return (type == Type.LINE_BREAK || (type == Type.COMMENT && data.endsWith("\n")));
	}

	@Override
	public RelativePosition getFrontRelativePosition(int line, int column) {
		if ((endLine == line && endColumn + 1 == column) || (column == 1 && endLine + 1 == line && endsWithLineBreak())) {
			return RelativePosition.FRONT_ADJACENT;
		} else if (endLine > line || (endLine == line && endColumn + 1 > column)) {
			return RelativePosition.AFTER;
		}
		
		return RelativePosition.BEFORE;
	}
	
	@Override
	public RelativePosition getBackRelativePosition(int line, int column) {
		if (startLine < line || (startLine == line && startColumn < column + 1)) {
			return RelativePosition.BEFORE;
		} else if (startLine == line && startColumn == column + 1) {
			return RelativePosition.BACK_ADJACENT;
		}
		return RelativePosition.AFTER;
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
			stringBuilder.append(">" + data + "</formattingitem>");
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
}
