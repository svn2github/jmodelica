package org.jmodelica.util;

/**
 * An object that holds the value and position of some sort of formatting. It can, for example, hold the position,
 * extent and actual string representation of a comment or whitespaces forming indentation.
 */
public class FormattingItem {
	private final static int COLUMN_BITS					= 12;
	private final static int COLUMN_MASK					= (1 << COLUMN_BITS) - 1;

	public final static short TYPE_NON_BREAKING_WHITESPACE	= 0;
	public final static short TYPE_LINE_TERMINATOR			= 1;
	public final static short TYPE_COMMENT					= 2;
	public final static short TYPE_DELIMITER				= 3;

	private short type;
	private String data;
	private int startPosition;
	private int endPosition;

	/**
	 * Creates a <code>FormattingItem</code>
	 * @param type the type of this item, should be one of <code>TYPE_*</code>
	 * @param data the string representation of what this item holds, such as an actual comment.
	 * @param startLine the line in the source code at which this item begins.
	 * @param startColumn the column in the source code at which this item begins.
	 * @param endLine the line in the source code at which this item ends. 
	 * @param endColumn the column in the source code at which this item ends.
	 */
	public FormattingItem(short type, String data, int startLine, int startColumn,
			int endLine, int endColumn) {
		this.type = type;
		this.data = data;
		startPosition = compressPosition(startLine, startColumn);
		endPosition = compressPosition(endLine, endColumn);
	}
	
	/**
	 * Compresses two integers containing line number and column number into one. The column is stored in the 12
	 * least significant bits, which means it cannot be larger than 4095. The rest of the bits are reserved for the
	 * line number.
	 * @param line the line number to compress.
	 * @param column the column number to compress.
	 * @return an integer containing both the column number (the 12 least significant bits) and line number (the
	 * rest of the bits).
	 */
	private int compressPosition(int line, int column) {
		return (line << COLUMN_BITS) | column;
	}

	/**
	 * Gets the type of this <code>FormattingItem</code>.
	 * @return the type of this item.
	 */
	public short getType() {
		return type;
	}
	
	/**
	 * Gets the string representation of what this item actually holds, such as an actual comment.
	 * @return the string representation of what this <code>FormattingItem</code> holds.
	 */
	public String getData() {
		return data;
	}

	/**
	 * Sets a new position of where this item begins.
	 * @param newStartLine the line in the source code at which this item begins.
	 * @param newStartColumn the column in the source code at which this item begins.
	 */
	public void newStart(int newStartLine, int newStartColumn) {
		startPosition = compressPosition(newStartLine, newStartColumn);
	}

	/**
	 * Sets a new position of where this item extends to.
	 * @param newEndLine the line in the source code at which this item ends.
	 * @param newEndColumn the column in the source code at which this item ends.
	 */
	public void newEnd(int newEndLine, int newEndColumn) {
		endPosition = compressPosition(newEndLine, newEndColumn);
	}

	/**
	 * Gets the line in the source code where this object begins.
	 * @return the line in the source code at which this item begins.
	 */
	public int getStartLine() {
		return (startPosition >>> COLUMN_BITS);
	}
	
	/**
	 * Gets the column in the source code where this object begins.
	 * @return the column in the source code at which this item begins.
	 */
	public int getStartColumn() {
		return (startPosition & COLUMN_MASK);
	}
	
	/**
	 * Gets the line in the source code where this objects ends.
	 * @return the line in the source code at which this item ends.
	 */
	public int getEndLine() {
		return (endPosition >>> COLUMN_BITS);
	}
	
	/**
	 * Gets the column in the source code where this object ends.
	 * @return the column in the source code at which this item ends.
	 */
	public int getEndColumn() {
		return (endPosition & COLUMN_MASK);
	}
}
