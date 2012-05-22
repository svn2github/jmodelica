package org.jmodelica.util;

import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;

/**
 * An object that holds formatting information such as indentation and comments. 
 */
public class FormattingInfo implements Iterable<ScannedFormattingItem> {
	private LinkedList<ScannedFormattingItem> formattingList;
	private boolean sorted;

	/**
	 * Creates a <code>FormattingInfo</code> instance.
	 */
	public FormattingInfo() {
		formattingList = new LinkedList<ScannedFormattingItem>();
		sorted = true;
	}

	/**
	 * Adds a scanned formatting item with information about what type of formatting this is and where it is
	 * positioned in the source code.
	 * @param type the type of formatting item.
	 * @param data the string data of this item, for example actual white spaces or comment.
	 * @param startLine the line at which this formatting item starts.
	 * @param startColumn the column at which this formatting item starts.
	 * @param endLine the line at which this formatting item ends.
	 * @param endColumn the column at which this formatting item ends.
	 */
	public void addItem(FormattingItem.Type type, String data, int startLine, int startColumn, int endLine, int endColumn ) {
		ScannedFormattingItem formattingItem = new ScannedFormattingItem(type, data, startLine, startColumn, endLine, endColumn);
		if (sorted && !formattingList.isEmpty() && formattingList.getLast().compareTo(formattingItem) > 0) {
			sorted = false;
		}
		formattingList.add(formattingItem);
	}

	/**
	 * Adds all formatting items in a collection to be part of the description of this formatting information.
	 * @param formattingItems a collection of <code>ScannedFormattingItem</code>s that are supposed to be added to
	 * this <code>FormattingInfo</code>.
	 */
	public void addAll(Collection<ScannedFormattingItem> formattingItems) {
		for (ScannedFormattingItem formattingItem : formattingItems) {
			if (sorted && !formattingList.isEmpty() && formattingList.getLast().compareTo(formattingItem) > 0) {
				sorted = false;
			}
			formattingList.add(formattingItem);
		}
	}
	
	/**
	 * Gets adjacent formatting items and merge those into fewer, larger items.
	 */
	public void mergeAdjacentFormattingItems() {
		if (!sorted) {
			Collections.sort(formattingList);
			sorted = true;
		}
		LinkedList<ScannedFormattingItem> newFormattingList = new LinkedList<ScannedFormattingItem>();

		while (!formattingList.isEmpty()) {
			Iterator<ScannedFormattingItem> formattingIterator = formattingList.iterator();
			ScannedFormattingItem currentItem = formattingIterator.next();
			formattingIterator.remove();

			while (formattingIterator.hasNext()) {
				ScannedFormattingItem otherItem = formattingIterator.next();
				FormattingItem.RelativePosition relativePosition = currentItem.getFrontRelativePosition(otherItem.getStartLine(), otherItem.getStartColumn());

				if (relativePosition == FormattingItem.RelativePosition.FRONT_ADJACENT) {
					currentItem = currentItem.mergeItems(FormattingItem.Adjacency.BACK, otherItem);
					formattingIterator.remove();
				} else if (relativePosition == FormattingItem.RelativePosition.AFTER) {
					break;
				}
			}
			newFormattingList.add(currentItem);
		}

		formattingList = newFormattingList;
		splitAfterFirstLineBreak();
	}

	private void splitAfterFirstLineBreak() {
		LinkedList<ScannedFormattingItem> newFormattingList = new LinkedList<ScannedFormattingItem>();

		for (ScannedFormattingItem item : formattingList) {
			ScannedFormattingItem splitResult[] = item.splitAfterFirstLineBreak();
			for (int i = 0; i < splitResult.length; i++) {
				newFormattingList.add(splitResult[i]);
			}
		}
		
		formattingList = newFormattingList;
	}

	/**
	 * Gets the sorted collection of scanned formatting items that this <code>FormattingInfo</code> holds. The
	 * collection is sorted in the order in which the the formatting items appeared when scanned. That is depending
	 * on their starting position and then their ending position.
	 * @return a sorted collection of the formatting items.
	 */
	/*public Collection<ScannedFormattingItem> getFormattingCollection() {
		if (!sorted) {
			Collections.sort(formattingList);
			sorted = true;
		}

		return formattingList;
	}*/

	/**
	 * Gets information about this <code>FormattingInfo</code> in an XML styled text string, which might be usable
	 * when debugging.
	 * @param printData if true, also the string data of the formatting items is printed.
	 * @return a String with information about the size of this formatting info, its formatting items' type,
	 * starting and ending position and if <code>printData</code> is true also the actual string data the
	 * formatting items hold.
	 */
	public String getInformationString(boolean printData) {
		StringBuilder stringBuilder = new StringBuilder();

		stringBuilder.append("<formatting size=\"" + formattingList.size() + "\">\n");
		for (ScannedFormattingItem formattingItem : formattingList) {
			stringBuilder.append("    " + formattingItem.getInformationString(printData) + "\n");
		}
		stringBuilder.append("</formatting>");

		return stringBuilder.toString();
	}

	/**
	 * Gets information about this <code>FormattingInfo</code> in an XML styled text string, which might be usable
	 * when debugging. Calling this method is identical to calling getInformationString(false).
	 * @return a String with information about the size of this formatting info, its formatting items' type and
	 * starting and ending position.
	 */
	public String getInformationString() {
		return getInformationString(false);
	}
	
	/**
	 * Determines whether this <code>FormattingInfo</code> contains any scanned formatting items or not.
	 * @return true if this <code>FormattingInfo</code> contains one or more scanned formatting items, otherwise
	 * false.
	 */
	public boolean isEmpty() {
		return formattingList.isEmpty();
	}

	@Override
	public String toString() {
		StringBuilder stringBuilder = new StringBuilder();

		stringBuilder.append("[");
		
		for (ScannedFormattingItem formattingItem : formattingList) {
			stringBuilder.append("\"" + formattingItem.toString() + "\", ");
		}
		
		if (formattingList.size() > 0) {
			stringBuilder.delete(stringBuilder.length() - 2, stringBuilder.length());
		}
		
		stringBuilder.append("]");

		return stringBuilder.toString();
	}

	@Override
	public Iterator<ScannedFormattingItem> iterator() {
		Iterator<ScannedFormattingItem> iterator = formattingList.iterator();

		return iterator;
	}
}