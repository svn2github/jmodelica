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
package org.jmodelica.util.formattedPrint;

import java.util.LinkedList;
import java.util.Stack;

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
	 * Sets a new position of where this item begins using another scanned formatting item's starting position.
	 * @param itemToStartFrom the <code>ScannedFormattingItem</code> from which to get the new starting position.
	 */
	public void newStart(ScannedFormattingItem itemToStartFrom) {
		startLine = itemToStartFrom.startLine;
		startColumn = itemToStartFrom.startColumn;
	}

	/**
	 * Sets a new position of where this item ends using another scanned formatting item's ending position.
	 * @param itemToEndAt the <code>ScannedFormattingItem</code> from which to get the new ending position.
	 */
	public void newEnd(ScannedFormattingItem itemToEndAt) {
		endLine = itemToEndAt.endLine;
		endColumn = itemToEndAt.endColumn;
	}

	@Override
	protected boolean endsWithLineBreak() {
		return (!subItems.isEmpty() && subItems.getLast().endsWithLineBreak());
	}
	
	@Override
	public ScannedFormattingItem mergeItems(Adjacency where, FormattingItem otherItem) {
		if (where == Adjacency.NONE || !otherItem.isScanned()) {
			return this;
		}

		ScannedFormattingItem scannedItem = (ScannedFormattingItem) otherItem;
		if (where == Adjacency.FRONT) {
			newStart(scannedItem);

			if (scannedItem.isScannedMixed()) {
				subItems.addAll(0, ((MixedFormattingItem) otherItem).subItems);
			} else {
				subItems.addFirst(scannedItem);
			}
		} else if (where == Adjacency.BACK) {
			newEnd(scannedItem);

			if (scannedItem.isScannedMixed()) {
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
			if (currentItem.endsWithLineBreak()) {
				break;
			}
		}
		
		while (currentSubItemIndex < subItems.size()) {
			lastPart = lastPart.mergeItems(Adjacency.BACK, subItems.get(currentSubItemIndex++));
		}
		
		if (firstPart.isEmptyDefault()) {
			ScannedFormattingItem[] result = new ScannedFormattingItem[1];
			result[0] = (ScannedFormattingItem) lastPart;
			return result;
		} else if (lastPart.isEmptyDefault()) {
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
	
	@Override
	public DefaultFormattingItem copyWhitepacesFromFormatting() {
		Stack<String> stringStack = new Stack<String>();
		for (int i = subItems.size() - 1; i >= 0; i--) {
			ScannedFormattingItem formattingItem = subItems.get(i);
			if (formattingItem.endsWithLineBreak()) {
				break;
			}
			if (formattingItem.type == Type.NON_BREAKING_WHITESPACE) {
				stringStack.push(formattingItem.data);
			}
		}
		
		StringBuilder dataBuilder = new StringBuilder();
		while (!stringStack.isEmpty()) {
			dataBuilder.append(stringStack.pop());
		}
		
		return new DefaultFormattingItem(dataBuilder.toString());
	}
	
	@Override
	public final boolean isScannedMixed() {
		return true;
	}

}
