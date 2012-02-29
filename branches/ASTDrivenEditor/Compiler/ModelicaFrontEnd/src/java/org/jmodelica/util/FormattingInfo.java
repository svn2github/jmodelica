package org.jmodelica.util;

import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedList;

/**
 * An object that holds formatting information such as indentation and comments. 
 */
public class FormattingInfo {
	private Collection<ScannedFormattingItem> formattingList;

	/**
	 * Creates a <code>FormattingInfo</code> instance.
	 */
	public FormattingInfo() {
		formattingList = new LinkedList<ScannedFormattingItem>();
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
		formattingList.add(formattingItem);
	}
	
	/**
	 * Gets adjacent formatting items and merge those into fewer, larger items.
	 */
	public void mergeAdjacentFormattingItems() {
		Collection<ScannedFormattingItem> newFormattingList = new LinkedList<ScannedFormattingItem>();

		while (!formattingList.isEmpty()) {
			Iterator<ScannedFormattingItem> formattingIterator = formattingList.iterator();
			ScannedFormattingItem currentItem = formattingIterator.next();
			formattingIterator.remove();

			while (formattingIterator.hasNext()) {
				ScannedFormattingItem otherItem = formattingIterator.next();
				FormattingItem.Adjacency adjacency = currentItem.getAdjacency(otherItem);

				if (adjacency != FormattingItem.Adjacency.NONE) {
					currentItem = currentItem.mergeItems(adjacency, otherItem);
					formattingIterator.remove();
				}
			}

			newFormattingList.add(currentItem);
		}

		formattingList = newFormattingList;
		splitAfterFirstLineBreak();
	}

	private void splitAfterFirstLineBreak() {
		Collection<ScannedFormattingItem> newFormattingList = new LinkedList<ScannedFormattingItem>();

		for (ScannedFormattingItem item : formattingList) {
			ScannedFormattingItem splitResult[] = item.splitAfterFirstLineBreak();
			for (int i = 0; i < splitResult.length; i++) {
				newFormattingList.add(splitResult[i]);
			}
		}
		
		formattingList = newFormattingList;
	}

	/**
	 * Gets the collection of formatting items this <code>FormattingInfo</code> holds.
	 * @return a collection of the formatting items.
	 */
	public Collection<ScannedFormattingItem> getFormattingCollection() {
		return formattingList;
	}

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
}