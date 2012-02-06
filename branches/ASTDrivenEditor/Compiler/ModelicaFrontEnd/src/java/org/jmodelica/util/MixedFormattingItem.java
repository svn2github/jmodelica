package org.jmodelica.util;

import java.util.Deque;
import java.util.LinkedList;

/**
 * A <code>FormattingItem</code> that consists of several, smaller items.
 */
public class MixedFormattingItem extends FormattingItem {
	private Deque<FormattingItem> subItems;

	/**
	 * Creates a <code>MixedFormattingItem</code>.
	 * @param data the string representation of what this item holds, such as an actual comment.
	 * @param startLine the line in the source code at which this item begins.
	 * @param startColumn the column in the source code at which this item begins.
	 * @param endLine the line in the source code at which this item ends. 
	 * @param endColumn the column in the source code at which this item ends.
	 */
	public MixedFormattingItem(String data, int startLine, int startColumn, int endLine, int endColumn) {
		super(FormattingItem.TYPE_MIXED, data, startLine, startColumn, endLine, endColumn);
		subItems = new LinkedList<FormattingItem>();
	}
	
	@Override
	protected short getAdjacency(FormattingItem otherItem) {
    	if ((getStartLine() == otherItem.getEndLine() && getStartColumn() == otherItem.getEndColumn() + 1) ||
    			(otherItem.getType() == FormattingItem.TYPE_LINE_TERMINATOR && getStartLine() == otherItem.getEndLine() + 1 && getStartColumn() == 1)) {
    		return FRONT;
    	} else if (getEndLine() == otherItem.getStartLine() && getEndColumn() + 1 == otherItem.getStartColumn() ||
    			((subItems.getLast().getType() == FormattingItem.TYPE_LINE_TERMINATOR || subItems.getLast().getType() == FormattingItem.TYPE_COMMENT) && getEndLine() + 1 == otherItem.getStartLine() && otherItem.getStartColumn() == 1)) {
    		return BACK;
    	}

    	return NO_ADJACENCY;
    }
	
	@Override
	protected FormattingItem mergeItems(short where, FormattingItem otherItem, boolean appendData) {
		if (where == NO_ADJACENCY) {
			return this;
		}

		if (where == FRONT) {
			newStart(otherItem.startLine, otherItem.startColumn);
			subItems.addFirst(otherItem);
			if (appendData) {
				data = otherItem.data + data;
			}
		} else if (where == BACK) {
			System.out.println("Back merge: " + this + " with " + otherItem);
			newEnd(otherItem.endLine, otherItem.endColumn);
			subItems.addLast(otherItem);
			if (appendData) {
				data = data + otherItem.data;
			}
		}

		subItems.add(otherItem);
		return this;
	}

}
