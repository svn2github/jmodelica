package org.jmodelica.util;

import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedList;

/**
 * An object that holds formatting information such as indentation and comments. 
 */
public class FormattingInfo {
	private Collection<FormattingItem> formattingList;
	private Collection<FormattingItem> delimiterList;

	/**
	 * Creates a <code>FormattingInfo</code> instance.
	 */
	public FormattingInfo() {
		formattingList = new LinkedList<FormattingItem>();
		delimiterList = new LinkedList<FormattingItem>();
	}

	/**
	 * Adds formatting item with information about what type of formatting this is and where it is positioned in
	 * the source code.
	 * @param type the type of formatting item this is, should be one of <code>FormattingItem.TYPE_*.</code>
	 * @param data the string data of this item, eg. actual whitespaces or comment.
	 * @param startLine the line at which this formatting item starts.
	 * @param startColumn the column at which this formatting item starts.
	 * @param endLine the line at which this formatting item ends.
	 * @param endColumn the column at which this formatting item ends.
	 */
	public void addItem(short type, String data, int startLine, int startColumn, int endLine, int endColumn ) {
		FormattingItem formattingItem = new FormattingItem(type, data, startLine, startColumn, endLine, endColumn);
		if (type != FormattingItem.TYPE_DELIMITER) {
			formattingList.add(formattingItem);
		} else {
			delimiterList.add(formattingItem);
		}
	}
	
	/**
	 * Gets adjacent formatting items and merge those into fewer, larger items.
	 */
	public void mergeAdjacentFormattingItems() {
		Collection<FormattingItem> newFormattingList = new LinkedList<FormattingItem>();

		while (!formattingList.isEmpty()) {
			Iterator<FormattingItem> formattingIterator = formattingList.iterator();
			FormattingItem currentItem = formattingIterator.next();
			formattingIterator.remove();

			while (formattingIterator.hasNext()) {
				FormattingItem otherItem = formattingIterator.next();
				short adjacency = currentItem.getAdjacency(otherItem);

				if (adjacency != FormattingItem.NO_ADJACENCY) {
					currentItem = currentItem.mergeItems(adjacency, otherItem, true);
					formattingIterator.remove();
				}
			}

			newFormattingList.add(currentItem);
		}

		formattingList = newFormattingList;
	}

	/**
	 * Gets the collection of formatting items this <code>FormattingInfo</code> holds.
	 * @return a collection of the formatting items.
	 */
	public Collection<FormattingItem> getFormattingCollection() {
		return formattingList;
	}

	public String toString() {
		StringBuilder stringBuilder = new StringBuilder();

		stringBuilder.append("<formatting size=\"" + formattingList.size() + "\">\n");
		for (FormattingItem formattingItem : formattingList) {
			stringBuilder.append("    " + formattingItem.toString() + "\n");
		}
		stringBuilder.append("</formatting>");

		return stringBuilder.toString();
	}
}