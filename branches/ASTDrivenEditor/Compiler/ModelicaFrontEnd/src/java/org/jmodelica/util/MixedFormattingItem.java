package org.jmodelica.util;

import java.util.Deque;
import java.util.LinkedList;

/**
 * A <code>FormattingItem</code> that consists of several, smaller items.
 */
public class MixedFormattingItem extends FormattingItem {
	private LinkedList<FormattingItem> subItems;

	/**
	 * Creates a <code>MixedFormattingItem</code>.
	 * @param formattingItem the initial item that this <code>MixedFormattingItem</code> should consist of.
	 */
	public MixedFormattingItem(FormattingItem formattingItem) {
		super(FormattingItem.Type.MIXED, null, formattingItem.startLine, formattingItem.startColumn, formattingItem.endLine, formattingItem.endColumn);
		subItems = new LinkedList<FormattingItem>();
		subItems.add(formattingItem);
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
	
	@Override
	public Adjacency getAdjacency(FormattingItem otherItem) {
    	if ((getStartLine() == otherItem.getEndLine() && getStartColumn() == otherItem.getEndColumn() + 1) ||
    			(otherItem.getType() == FormattingItem.Type.LINE_BREAK && getStartLine() == otherItem.getEndLine() + 1 && getStartColumn() == 1)) {
    		return Adjacency.FRONT;
    	} else if (getEndLine() == otherItem.getStartLine() && getEndColumn() + 1 == otherItem.getStartColumn() ||
    			((subItems.getLast().getType() == FormattingItem.Type.LINE_BREAK || subItems.getLast().getType() == FormattingItem.Type.COMMENT) && getEndLine() + 1 == otherItem.getStartLine() && otherItem.getStartColumn() == 1)) {
    		return Adjacency.BACK;
    	}

    	return Adjacency.NONE;
    }
	
	@Override
	public FormattingItem mergeItems(Adjacency where, FormattingItem otherItem) {
		if (where == Adjacency.NONE || otherItem.getType() == Type.EMPTY) {
			return this;
		}

		if (where == Adjacency.FRONT) {
			newStart(otherItem.startLine, otherItem.startColumn);
			subItems.addFirst(otherItem);
		} else if (where == Adjacency.BACK) {
			newEnd(otherItem.endLine, otherItem.endColumn);
			subItems.addLast(otherItem);
		}

		return this;
	}
	
	@Override
	public FormattingItem[] splitAfterFirstLineBreak() {
		FormattingItem firstPart = new EmptyFormattingItem();
		FormattingItem lastPart = new EmptyFormattingItem();
		int currentSubItemIndex = 0;

		while (currentSubItemIndex < subItems.size()) {
			FormattingItem currentItem = subItems.get(currentSubItemIndex++);
			firstPart = firstPart.mergeItems(Adjacency.BACK, currentItem);
			if (currentItem.getType() == Type.LINE_BREAK) {
				break;
			}
		}
		
		while (currentSubItemIndex < subItems.size()) {
			lastPart = lastPart.mergeItems(Adjacency.BACK, subItems.get(currentSubItemIndex++));
		}
		
		if (firstPart.getType() == Type.EMPTY) {
			FormattingItem[] result = new FormattingItem[1];
			result[0] = lastPart;
			return result;
		} else if (lastPart.getType() == Type.EMPTY) {
			FormattingItem[] result = new FormattingItem[1];
			result[0] = firstPart;
			return result;
		}
		FormattingItem[] result = new FormattingItem[2];
		result[0] = firstPart;
		result[1] = lastPart;

		return result;
	}

	@Override
	public String toString() {
		StringBuilder stringBuilder = new StringBuilder();

		for (FormattingItem item : subItems) {
			stringBuilder.append(item);
		}

		return stringBuilder.toString();
	}

}
