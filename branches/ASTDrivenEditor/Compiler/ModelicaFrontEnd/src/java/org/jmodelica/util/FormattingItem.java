package org.jmodelica.util;

/**
 * An object that holds the value and position of some sort of formatting. It can, for example, hold the position,
 * extent and actual string representation of a comment or white spaces forming indentation.
 */
public class FormattingItem {
	public enum Type {
		NON_BREAKING_WHITESPACE,
		LINE_BREAK,
		COMMENT,
		MIXED,
		EMPTY;
	};

	public enum Adjacency {
		NONE,
		FRONT,
		BACK
	};

	private Type type;
	private String data;
	protected int startLine;
	protected int startColumn;
	protected int endLine;
	protected int endColumn;

	/**
	 * Creates a <code>FormattingItem</code>.
	 * @param type the type of this item.
	 * @param data the string representation of what this item holds, such as an actual comment.
	 * @param startLine the line in the source code at which this item begins.
	 * @param startColumn the column in the source code at which this item begins.
	 * @param endLine the line in the source code at which this item ends. 
	 * @param endColumn the column in the source code at which this item ends.
	 */
	public FormattingItem(Type type, String data, int startLine, int startColumn,
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
	public Type getType() {
		return type;
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
	 * <code>otherItem</code> is located right before this item in the code,
	 * <code>FormattingItem.Adjacency.FRONT</code> is returned. If it is located right after this item,
	 * <code>FormattingItem.Adjacency.BACK</code> is returned. Otherwise <code>NO_ADJACENCY</code> is returned.
	 * @param otherItem the other item to determine its adjacency relative to this one.
	 * @return <code>FormattingItem.Adjacency.FRONT</code> if <code>otherItem</code> is located right before this
	 * item in the source code. <code>FormattingItem.Adjacency.BACK</code> if <code>otherItem</code> is located
	 * right after this item in the source code. <code>FormattingItem.Adjacency.NONE</code> otherwise.
	 */
	public Adjacency getAdjacency(FormattingItem otherItem) {
    	if ((getStartLine() == otherItem.getEndLine() && getStartColumn() == otherItem.getEndColumn() + 1) ||
    			(otherItem.type == FormattingItem.Type.LINE_BREAK && getStartLine() == otherItem.getEndLine() + 1 && getStartColumn() == 1)) {
    		return Adjacency.FRONT;
    	} else if (getEndLine() == otherItem.getStartLine() && getEndColumn() + 1 == otherItem.getStartColumn() ||
    			(type == FormattingItem.Type.LINE_BREAK && getEndLine() + 1 == otherItem.getStartLine() && otherItem.getStartColumn() == 1)) {
    		return Adjacency.BACK;
    	}

    	return Adjacency.NONE;
    }

	/**
	 * Merges another item with this one if the items are adjacent, returning a new, mixed formatting item.
	 * @param where the adjacency of the other object relative to this one. For example
	 * <code>FormattingItem.Adjacency.FRONT</code> if it <code>otherItem</code> is located right before this item
	 * in the source code.
	 * @param otherItem the other item to expand this item with.
	 * @return this formatting item if there is no adjacency or a new <code>MixedFormattingItem</code> containing
	 * the merge if there is adjacency.
	 */
	public FormattingItem mergeItems(Adjacency where, FormattingItem otherItem) {
		if (where == Adjacency.NONE || otherItem.type == Type.EMPTY) {
			return this;
		}
		
		MixedFormattingItem mergedItems = new MixedFormattingItem(this);
		return mergedItems.mergeItems(where, otherItem);
	}
	
	public FormattingItem[] splitAfterFirstLineBreak() {
		FormattingItem[] result = new FormattingItem[1];
		result[0] = this;
		return result;
	}

	/**
	 * Gets information about this <code>FormattingItem</code> in an XML styled text string, which might be usable
	 * when debugging.
	 * @return a String with information about this item's type, starting position and ending position.
	 */
	public String getInformationString() {
		return "<formattingitem type=\"" + type +
				"\" startline=\"" + getStartLine() +
				"\" startcolumn=\"" + getStartColumn() +
				"\" endline=\"" + getEndLine() +
				"\" endcolumn=\"" + getEndColumn() +
				"\" />";
	}

	@Override
	public String toString() {
		return data;
	}
}
