package org.jmodelica.util;

import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedList;

import org.jmodelica.util.FormattingItem.Type;

/**
 * An object that holds formatting information such as indentation and comments. 
 */
public class FormattingInfo {
	private Collection<FormattingItem> formattingList;

	/**
	 * Creates a <code>FormattingInfo</code> instance.
	 */
	public FormattingInfo() {
		formattingList = new LinkedList<FormattingItem>();
	}

	/**
	 * Adds formatting item with information about what type of formatting this is and where it is positioned in
	 * the source code.
	 * @param type the type of formatting item this is.
	 * @param data the string data of this item, for example actual white spaces or comment.
	 * @param startLine the line at which this formatting item starts.
	 * @param startColumn the column at which this formatting item starts.
	 * @param endLine the line at which this formatting item ends.
	 * @param endColumn the column at which this formatting item ends.
	 */
	public void addItem(FormattingItem.Type type, String data, int startLine, int startColumn, int endLine, int endColumn ) {
		FormattingItem formattingItem = new FormattingItem(type, data, startLine, startColumn, endLine, endColumn);
		formattingList.add(formattingItem);
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
		Collection<FormattingItem> newFormattingList = new LinkedList<FormattingItem>();

		for (FormattingItem item : formattingList) {
			FormattingItem splitResult[] = item.splitAfterFirstLineBreak();
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
	public Collection<FormattingItem> getFormattingCollection() {
		return formattingList;
	}
	
	public String getInformationString() {
		StringBuilder stringBuilder = new StringBuilder();

		stringBuilder.append("<formatting size=\"" + formattingList.size() + "\">\n");
		for (FormattingItem formattingItem : formattingList) {
			stringBuilder.append("    " + formattingItem.getInformationString() + "\n");
		}
		stringBuilder.append("</formatting>");

		return stringBuilder.toString();
	}

	public String toString() {
		StringBuilder stringBuilder = new StringBuilder();

		stringBuilder.append("[");
		
		for (FormattingItem formattingItem : formattingList) {
			stringBuilder.append("\"" + formattingItem.toString() + "\", ");
		}
		
		if (formattingList.size() > 0) {
			stringBuilder.delete(stringBuilder.length() - 2, stringBuilder.length());
		}
		
		stringBuilder.append("]");

		return stringBuilder.toString();
	}
}