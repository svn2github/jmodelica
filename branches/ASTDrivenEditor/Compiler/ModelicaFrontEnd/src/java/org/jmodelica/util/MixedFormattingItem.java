package org.jmodelica.util;

import java.util.LinkedList;

/**
 * A <code>FormattingItem</code> that consists of several, smaller items.
 */
public class MixedFormattingItem extends ScannedFormattingItem {
	private LinkedList<ScannedFormattingItem> subItems;

	/**
	 * Creates a <code>MixedFormattingItem</code>.
	 * @param formattingItem the initial item that this <code>MixedFormattingItem</code> should consist of.
	 */
	public MixedFormattingItem(ScannedFormattingItem formattingItem) {
		super(FormattingItem.Type.MIXED, null, formattingItem.startLine, formattingItem.startColumn, formattingItem.endLine, formattingItem.endColumn);
		subItems = new LinkedList<ScannedFormattingItem>();
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
		if (!(otherItem instanceof ScannedFormattingItem)) {
			return Adjacency.NONE;
		}
		ScannedFormattingItem otherScannedItem = (ScannedFormattingItem) otherItem;

    	if ((startLine == otherScannedItem.endLine && startColumn == endColumn + 1) ||
    			(otherScannedItem.type == Type.LINE_BREAK && startLine == otherScannedItem.endLine + 1 && startColumn == 1)) {
    		return Adjacency.FRONT;
    	} else if (endLine == otherScannedItem.startLine && endColumn + 1 == otherScannedItem.startColumn ||
    			((subItems.getLast().type == Type.LINE_BREAK || subItems.getLast().type == Type.COMMENT) && endLine + 1 == otherScannedItem.startLine && otherScannedItem.startColumn == 1)) {
    		return Adjacency.BACK;
    	}

    	return Adjacency.NONE;
    }
	
	@Override
	public ScannedFormattingItem mergeItems(Adjacency where, FormattingItem otherItem) {
		if (where == Adjacency.NONE || !(otherItem instanceof ScannedFormattingItem)) {
			return this;
		}

		ScannedFormattingItem scannedItem = (ScannedFormattingItem) otherItem;
		if (where == Adjacency.FRONT) {
			newStart(scannedItem.startLine, scannedItem.startColumn);

			if (scannedItem instanceof MixedFormattingItem) {
				subItems.addAll(0, ((MixedFormattingItem) otherItem).subItems);
			} else {
				subItems.addFirst(scannedItem);
			}
		} else if (where == Adjacency.BACK) {
			newEnd(scannedItem.endLine, scannedItem.endColumn);

			if (scannedItem instanceof MixedFormattingItem) {
				subItems.addAll(subItems.size(), ((MixedFormattingItem) otherItem).subItems);
			} else {
				subItems.addLast(scannedItem);
			}
		}

		return this;
	}
	
	@Override
	public ScannedFormattingItem[] splitAfterFirstLineBreak() {
		FormattingItem firstPart = new EmptyFormattingItem();
		FormattingItem lastPart = new EmptyFormattingItem();
		int currentSubItemIndex = 0;

		while (currentSubItemIndex < subItems.size()) {
			ScannedFormattingItem currentItem = subItems.get(currentSubItemIndex++);
			firstPart = firstPart.mergeItems(Adjacency.BACK, currentItem);
			if (currentItem.type == Type.LINE_BREAK) {
				break;
			}
		}
		
		while (currentSubItemIndex < subItems.size()) {
			lastPart = lastPart.mergeItems(Adjacency.BACK, subItems.get(currentSubItemIndex++));
		}
		
		if (firstPart.type == Type.EMPTY) {
			ScannedFormattingItem[] result = new ScannedFormattingItem[1];
			result[0] = (ScannedFormattingItem) lastPart;
			return result;
		} else if (lastPart.type == Type.EMPTY) {
			ScannedFormattingItem[] result = new ScannedFormattingItem[1];
			result[0] = (ScannedFormattingItem) firstPart;
			return result;
		}
		ScannedFormattingItem[] result = new ScannedFormattingItem[2];
		result[0] = (ScannedFormattingItem) firstPart;
		result[1] = (ScannedFormattingItem) lastPart;

		return result;
	}

	@Override
	public String toString() {
		StringBuilder stringBuilder = new StringBuilder();

		for (ScannedFormattingItem item : subItems) {
			stringBuilder.append(item);
		}

		return stringBuilder.toString();
	}

}
