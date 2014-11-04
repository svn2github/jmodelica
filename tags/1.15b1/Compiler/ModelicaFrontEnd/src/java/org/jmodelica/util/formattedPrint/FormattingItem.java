package org.jmodelica.util.formattedPrint;

import beaver.Symbol;

/**
 * An object that holds some sort of formatting information, ranging from an empty item to a mixed item which has
 * been combined from several sub items.
 */
public abstract class FormattingItem {
	public enum Type {
		DEFAULT,
		NON_BREAKING_WHITESPACE,
		LINE_BREAK,
		COMMENT,
		VISIBILITY_INFO,
		PARENTHESIS,
		MIXED,
		EMPTY;
	};

	public enum Adjacency {
		NONE,
		FRONT,
		BACK
	};
	
	public enum RelativePosition {
		UNDEFINED,
		BEFORE,
		FRONT_ADJACENT,
		INSIDE,
		BACK_ADJACENT,
		AFTER
	}
	
	public static final FormattingItem NO_FORMATTING = new EmptyFormattingItem();
	public static final FormattingItem NOT_FORMATTED = new EmptyFormattingItem();
	
	protected Type type;
	protected String data;

	/**
	 * Creates a <code>FormattingItem</code>.
	 * @param type the type of this item.
	 * @param data the string representation of what this item holds, such as an actual comment.
	 */
	public FormattingItem(Type type, String data) {
		this.type = type;
		this.data = data;
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
	public abstract Adjacency getAdjacency(FormattingItem otherItem);

	/**
	 * TODO: This javadoc is outdated
	 * Gets the position this formatting item's end relative to a symbol's starting position. It can either be
	 * before this symbol's start, front adjacent to it, after it or the result can be undefined. The latter
	 * happens if this formatting item is not a <code>ScannedFormattingItem</code> and thus doesn't have a valid
	 * position.
	 * @param symbol the <code>Symbol</code>, from which to get the starting position and compare to the ending
	 * position of this <code>FormattingItem</code>. 
	 * @return if this <code>FormattingItem</code> is not a <code>ScannedFormattingItem</code>, then
	 * <code>RelativePosition.UNDEFINED</code> is returned. Otherwise, if it ends just one column before
	 * <code>symbol</code> starts, then <code>RelativePosition.FRONT_ADJACENT</code> is returned. If it ends before
	 * that then <code>RelativePosition.BEFORE</code> is returned. Otherwise <code>RelativePosition.AFTER</code> is
	 * returned.
	 */
	public RelativePosition getFrontRelativePosition(Symbol symbol) {
		return getFrontRelativePosition(Symbol.getLine(symbol.getStart()), Symbol.getColumn(symbol.getStart()));
	}

	/**
	 * TODO: This javadoc is outdated
	 * Gets the position this formatting item's start relative to a item's ending position. It can either be
	 * before this symbol's end, back adjacent to it, after it or the result can be undefined. The latter happens
	 * if this formatting item is not a <code>ScannedFormattingItem</code> and thus doesn't have a valid position.
	 * @param item the <code>ScannedFormattingItem</code>, from which to get the ending position and compare to the starting
	 * position of this <code>FormattingItem</code>. 
	 * @return if this <code>FormattingItem</code> is not a <code>ScannedFormattingItem</code>, then
	 * <code>RelativePosition.UNDEFINED</code> is returned. Otherwise, if it starts just one column after
	 * <code>item</code> ends, then <code>RelativePosition.BACK_ADJACENT</code> is returned. If it starts after
	 * that then <code>RelativePosition.AFTER</code> is returned. Otherwise <code>RelativePosition.BEFORE</code> is
	 * returned.
	 */
	public RelativePosition getBackRelativePosition(ScannedFormattingItem item) {
		return getBackRelativePosition(item.endLine, item.endColumn);
	}

	/**
	 * TODO: This javadoc is outdated
	 * Gets the position this formatting item's end relative to a item's starting position. It can either be
	 * before this symbol's start, front adjacent to it, after it or the result can be undefined. The latter
	 * happens if this formatting item is not a <code>ScannedFormattingItem</code> and thus doesn't have a valid
	 * position.
	 * @param item the <code>ScannedFormattingItem</code>, from which to get the starting position and compare to the ending
	 * position of this <code>FormattingItem</code>. 
	 * @return if this <code>FormattingItem</code> is not a <code>ScannedFormattingItem</code>, then
	 * <code>RelativePosition.UNDEFINED</code> is returned. Otherwise, if it ends just one column before
	 * <code>item</code> starts, then <code>RelativePosition.FRONT_ADJACENT</code> is returned. If it ends before
	 * that then <code>RelativePosition.BEFORE</code> is returned. Otherwise <code>RelativePosition.AFTER</code> is
	 * returned.
	 */
	public RelativePosition getFrontRelativePosition(ScannedFormattingItem item) {
		return getFrontRelativePosition(item.startLine, item.startColumn);
	}

	/**
	 * TODO: This javadoc is outdated
	 * Gets the position this formatting item's start relative to a symbol's ending position. It can either be
	 * before this symbol's end, back adjacent to it, after it or the result can be undefined. The latter happens
	 * if this formatting item is not a <code>ScannedFormattingItem</code> and thus doesn't have a valid position.
	 * @param symbol the <code>Symbol</code>, from which to get the ending position and compare to the starting
	 * position of this <code>FormattingItem</code>. 
	 * @return if this <code>FormattingItem</code> is not a <code>ScannedFormattingItem</code>, then
	 * <code>RelativePosition.UNDEFINED</code> is returned. Otherwise, if it starts just one column after
	 * <code>symbol</code> ends, then <code>RelativePosition.BACK_ADJACENT</code> is returned. If it starts after
	 * that then <code>RelativePosition.AFTER</code> is returned. Otherwise <code>RelativePosition.BEFORE</code> is
	 * returned.
	 */
	public RelativePosition getBackRelativePosition(Symbol symbol) {
		return getBackRelativePosition(Symbol.getLine(symbol.getEnd()), Symbol.getColumn(symbol.getEnd()));
	}

	/**
	 * TODO: This javadoc is outdated
	 * Gets the position this formatting item's end relative to something starting at (<code>line</code>,
	 * <code>column</code>). This item can either be before this position, front adjacent to it, after it or the
	 * result can be undefined. The latter happens if this formatting item is not a
	 * <code>ScannedFormattingItem</code> and thus doesn't have a valid position.
	 * @param line the line, from which to get the relative position.
	 * @param column the column, from which to get the relative position.
	 * @return if this <code>FormattingItem</code> is not a <code>ScannedFormattingItem</code>, then
	 * <code>RelativePosition.UNDEFINED</code> is returned. Otherwise, if it ends just one column before
	 * (<code>line</code>, <code>column</code>) <code>RelativePosition.FRONT_ADJACENT</code> is returned. If it
	 * ends before that then <code>RelativePosition.BEFORE</code> is returned. Otherwise
	 * <code>RelativePosition.AFTER</code> is returned.
	 */
	public abstract RelativePosition getFrontRelativePosition(int line, int column);
	
	/**
	 * TODO: This javadoc is outdated
	 * Gets the position this formatting item's start relative to something ending at (<code>line</code>,
	 * <code>column</code>). This item can either be before this position, back adjacent to it, after it or the
	 * result can be undefined. The latter happens if this formatting item is not a
	 * <code>ScannedFormattingItem</code> and thus doesn't have a valid position.
	 * @param line the line, from which to get the relative position.
	 * @param column the column, from which to get the relative position.
	 * @return if this <code>FormattingItem</code> is not a <code>ScannedFormattingItem</code>, then
	 * <code>RelativePosition.UNDEFINED</code> is returned. Otherwise, if it starts just one column after
	 * (<code>line</code>, <code>column</code>) <code>RelativePosition.BACK_ADJACENT</code> is returned. If it
	 * starts after that then <code>RelativePosition.AFTER</code> is returned. Otherwise
	 * <code>RelativePosition.BEFORE</code> is returned.
	 */
	public abstract RelativePosition getBackRelativePosition(int line, int column);

	/**
	 * Merges another item with this one if the items are adjacent (determined by the parameter <code>where</code>),
	 * returning a new, mixed formatting item.
	 * @param where the adjacency of the other object relative to this one. For example
	 * <code>FormattingItem.Adjacency.FRONT</code> if it <code>otherItem</code> is located right before this item
	 * in the source code.
	 * @param otherItem the other item to expand this item with.
	 * @return this formatting item if there is no adjacency or a new <code>MixedFormattingItem</code> containing
	 * the merge if there is adjacency.
	 */
	public abstract FormattingItem mergeItems(Adjacency where, FormattingItem otherItem);

	@Override
	public String toString() {
		return data;
	}
	
	/**
	 * Creates a new <code>DefaultFormattingItem</code> containing all the whitespaces that this
	 * <code>FormattingItem</code> contains after its last line break.
	 * This should make it easy to get indentation from this <code>FormattingItem</code>.
	 * @return a new <code>DefaultFormattingItem</code> containing all the whitespaces that this
	 * <code>FormattingItem</code> contains after its last line break.
	 */
	public abstract DefaultFormattingItem copyWhitepacesFromFormatting();
	
	/**
	 * Determines whether this <code>FormattingItem</code> is a <code>ScannedFormattingItem</code> or not.
	 * @return true if this is a <code>ScannedFormattingItem</code>, otherwise false.
	 */
	public abstract boolean isScanned();

	/**
	 * Determines whether this <code>FormattingItem</code> is a <code>MixedFormattingItem</code> or not.
	 * @return true if this is a <code>MixedFormattingItem</code>, otherwise false.
	 */
	public abstract boolean isScannedMixed();

	/**
	 * Determines whether this <code>FormattingItem</code> is a <code>EmptyFormattingItem</code> or not.
	 * @return true if this is a <code>EmptyFormattingItem</code>, otherwise false.
	 */
	public abstract boolean isEmptyDefault();
}
