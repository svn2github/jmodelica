package org.jmodelica.util;

/**
 * An object that holds the value and position of some sort of formatting. It can, for example, hold the position,
 * extent and actual string representation of a comment or whitespaces forming indentation.
 */
public class FormattingItem {
	public final static short TYPE_NON_BREAKING_WHITESPACE	= 0;
	public final static short TYPE_LINE_TERMINATOR			= 1;
	public final static short TYPE_COMMENT					= 2;
	public final static short TYPE_DELIMITER				= 3;
	public final static short TYPE_MIXED					= 4;

	public final String[] NAMES								= {
			"non-breaking-whitespace",
			"line-terminator",
			"comment",
			"delimiter",
			"mixed"
		};

	public final static short NO_ADJACENCY					= 0;
	public final static short FRONT							= 1;
	public final static short BACK							= 2;

	private short type;
	protected String data;
	protected int startLine;
	protected int startColumn;
	protected int endLine;
	protected int endColumn;

	/**
	 * Creates a <code>FormattingItem</code>.
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
		this.startLine = startLine;
		this.startColumn = startColumn;
		this.endLine = endLine;
		this.endColumn = endColumn;
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
		startLine = newStartLine;
		startColumn = newStartColumn;
	}

	/**
	 * Sets a new position of where this item extends to.
	 * @param newEndLine the line in the source code at which this item ends.
	 * @param newEndColumn the column in the source code at which this item ends.
	 */
	public void newEnd(int newEndLine, int newEndColumn) {
		endLine = newEndLine;
		endColumn = newEndColumn;
	}

	/**
	 * Gets the line in the source code where this object begins.
	 * @return the line in the source code at which this item begins.
	 */
	public int getStartLine() {
		return startLine;
	}
	
	/**
	 * Gets the column in the source code where this object begins.
	 * @return the column in the source code at which this item begins.
	 */
	public int getStartColumn() {
		return startColumn;
	}
	
	/**
	 * Gets the line in the source code where this objects ends.
	 * @return the line in the source code at which this item ends.
	 */
	public int getEndLine() {
		return endLine;
	}
	
	/**
	 * Gets the column in the source code where this object ends.
	 * @return the column in the source code at which this item ends.
	 */
	public int getEndColumn() {
		return endColumn;
	}

	/**
	 * Determines whether another <code>FormattingItem</code> is adjacent to this one in the source code. If
	 * <code>otherItem</code> is located right before this item in the code, <code>FormattingItem.FRONT</code> is
	 * returned. If it is located right after this item, <code>FormattingItem.BACK</code> is returned. Otherwise
	 * <code>NO_ADJACENCY</code> is returned.
	 * @param otherItem the other item to determine its adjacency relative to this one.
	 * @return <code>FormattingItem.FRONT</code> if <code>otherItem</code> is located right before this item in
	 * the source code. <code>FormattingItem.BACK</code> if <code>otherItem</code> is located right after this item
	 * in the source code. <code>FormattingItem.NO_ADJACENCY</code> otherwise.
	 */
	protected short getAdjacency(FormattingItem otherItem) {
    	if ((getStartLine() == otherItem.getEndLine() && getStartColumn() == otherItem.getEndColumn() + 1) ||
    			(otherItem.type == FormattingItem.TYPE_LINE_TERMINATOR && getStartLine() == otherItem.getEndLine() + 1 && getStartColumn() == 1)) {
    		return FRONT;
    	} else if (getEndLine() == otherItem.getStartLine() && getEndColumn() + 1 == otherItem.getStartColumn() ||
    			(type == FormattingItem.TYPE_LINE_TERMINATOR && getEndLine() + 1 == otherItem.getStartLine() && otherItem.getStartColumn() == 1)) {
    		return BACK;
    	}

    	return NO_ADJACENCY;
    }

	/**
	 * Merges another item with this one if the items are adjacent, returning a new, mixed formatting item.
	 * @param where the adjacency of the other object relative to this one. Eg. <code>FormattingItem.FRONT</code>
	 * if it <code>otherItem</code> is located right before this item in the source code.
	 * @param otherItem the other item to expand this item with.
	 * @param appendData if true, then append the textual representation of what <code>otherItem</code> holds, such
	 * as a comment, to this items string representation. Otherwise the string representation is left unchanged.
	 * @return this formatting item if there is no adjacency or a new <code>MixedFormattingItem</code> containing
	 * the merge if there is adjacency.
	 */
	protected FormattingItem mergeItems(short where, FormattingItem otherItem, boolean appendData) {
		if (where == NO_ADJACENCY) {
			return this;
		}
		
		MixedFormattingItem mergedItems = new MixedFormattingItem(data, getStartLine(), getStartColumn(), getEndLine(), getEndColumn());
		return mergedItems.mergeItems(where, otherItem, appendData);
	}

	public String toString() {
		return "<formattingitem type=\"" + NAMES[type] +
				"\" startline=\"" + getStartLine() +
				"\" startcolumn=\"" + getStartColumn() +
				"\" endline=\"" + getEndLine() +
				"\" endcolumn=\"" + getEndColumn() +
				"\" />";
	}
}
