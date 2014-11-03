package org.jmodelica.util.formattedPrint;

import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.TreeSet;

import org.jmodelica.util.formattedPrint.FormattingItem.Adjacency;
import org.jmodelica.util.formattedPrint.FormattingItem.RelativePosition;
import org.jmodelica.util.formattedPrint.FormattingItem.Type;
import org.jmodelica.util.formattedPrint.FormattingLocator.Locator;

import beaver.Symbol;

/**
 * An object that holds formatting information such as indentation and comments. 
 */
public class FormattingInfo implements Iterable<ScannedFormattingItem> {
	private TreeSet<ScannedFormattingItem> formattingList;

	/**
	 * Creates a <code>FormattingInfo</code> instance.
	 */
	public FormattingInfo() {
		formattingList = new TreeSet<ScannedFormattingItem>();
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
	 * Adds a set of parenthesis
	 * @param left symbol that represents the opening parenthesis
	 * @param right symbol that represents the closing parenthesis
	 */
	public void addParenthesis(Symbol left, Symbol right) {
		addItem(FormattingItem.Type.PARENTHESIS, "(", Symbol.getLine(left.getStart()), Symbol.getColumn(left.getStart()), Symbol.getLine(left.getEnd()), Symbol.getColumn(left.getEnd()));
		addItem(FormattingItem.Type.PARENTHESIS, ")", Symbol.getLine(right.getStart()), Symbol.getColumn(right.getStart()), Symbol.getLine(right.getEnd()), Symbol.getColumn(right.getEnd()));
	}
	
	/**
	 * Finds adjacent formatting items to <code>item</code> and merges.
	 * A new formatting item representing all adjacent formatting is returned. 
	 * @param item Item that should be merged with adjacent formatting
	 * @return Complete node with adjacent formatting.
	 */
	public FormattingItem addFormattingRest(FormattingItem item) {
		FormattingItem otherItem;
		do {
			otherItem = getFrontAdjacentFormatting(item);
			item = item.mergeItems(FormattingItem.Adjacency.FRONT, otherItem);
		} while (otherItem != FormattingItem.NO_FORMATTING);
		
		do {
			otherItem = getBackAdjacentFormatting(item);
			item = item.mergeItems(FormattingItem.Adjacency.BACK, otherItem);
		} while (otherItem != FormattingItem.NO_FORMATTING);
		return item;
	}
	
	/**
	 * Adds all formatting items in a collection to be part of the description of this formatting information.
	 * @param formattingItems a collection of <code>ScannedFormattingItem</code>s that are supposed to be added to
	 * this <code>FormattingInfo</code>.
	 */
	public void addAll(Collection<ScannedFormattingItem> formattingItems) {
		formattingList.addAll(formattingItems);
	}
	
	/**
	 * Gets adjacent formatting items and merge those into fewer, larger items.
	 */
	public void mergeAdjacentFormattingItems() {
		if (formattingList.size() <= 1)
			return;
		
		TreeSet<ScannedFormattingItem> newFormattingList = new TreeSet<ScannedFormattingItem>();
		Iterator<ScannedFormattingItem> it = formattingList.iterator();
		
		ScannedFormattingItem currentItem = it.next();
		while (it.hasNext()) {
			ScannedFormattingItem nextItem = null;
			while (it.hasNext()) {
				nextItem = it.next();
				FormattingItem.RelativePosition relativePosition = currentItem.getFrontRelativePosition(nextItem.getStartLine(), nextItem.getStartColumn());
				
				if (relativePosition == FormattingItem.RelativePosition.FRONT_ADJACENT) {
					currentItem = currentItem.mergeItems(FormattingItem.Adjacency.BACK, nextItem);
				} else if (relativePosition == FormattingItem.RelativePosition.BEFORE) {
					break;
				}
			}
			
			Collections.addAll(newFormattingList, currentItem.splitAfterFirstLineBreak());
			currentItem = nextItem;
		}
		formattingList = newFormattingList;
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
	
	/**
	 * Determines whether this <code>FormattingInfo</code> contains any scanned formatting items or not.
	 * @return true if this <code>FormattingInfo</code> contains one or more scanned formatting items, otherwise
	 * false.
	 */
	public boolean isEmpty() {
		return formattingList.isEmpty();
	}

	/*
	 * (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
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
	
	/**
	 * Calculates front adjacent formatting for <code>node</code>.
	 * @param node node specifying position
	 * @return Front adjacent formatting, if found else NO_FORMATTING is returned.
	 */
	public FormattingItem getFrontAdjacentFormatting(FormattingItem node) {
		if (!node.isScanned())
			return FormattingItem.NO_FORMATTING;
		ScannedFormattingItem sfi = (ScannedFormattingItem) node;
		ScannedFormattingItem item = formattingList.floor(ScannedFormattingItem.getCompareItem(sfi.startLine, sfi.startColumn));
		if (item == null)
			return FormattingItem.NO_FORMATTING;
		Adjacency adjacency = item.getAdjacency(node);
		if (adjacency == Adjacency.BACK) {
			formattingList.remove(item);
			return item;
		}
		return FormattingItem.NO_FORMATTING;
	}
	
	/**
	 * Calculates front adjacent formatting for the symbol <code>node</code>.
	 * @param node node specifying position
	 * @return Front adjacent formatting, if found else NO_FORMATTING is returned.
	 */
	public FormattingItem getFrontAdjacentFormatting(Symbol node) {
		ScannedFormattingItem compareItem = ScannedFormattingItem.getStartCompareItem(node);
		ScannedFormattingItem item = formattingList.floor(compareItem);
		if (item != null) {
			RelativePosition relativePosition = item.getFrontRelativePosition(node);
			if (relativePosition == RelativePosition.FRONT_ADJACENT || relativePosition == RelativePosition.INSIDE) {
				formattingList.remove(item);
				return item;
			}
		}
		item = formattingList.ceiling(compareItem);
		if (item != null) {
			RelativePosition relativePosition = item.getFrontRelativePosition(node);
			if (relativePosition == RelativePosition.FRONT_ADJACENT || relativePosition == RelativePosition.INSIDE) {
				formattingList.remove(item);
				return item;
			}
		}
		return FormattingItem.NO_FORMATTING;
	}
	
	/**
	 * Calculates inside formatting based on position given by <code>locator</code>
	 * @param locator Locator that specifies position and adjacency
	 * @return Formatting item that matches <code>locator</code>. NO_FORMATTING is
	 * returned if no suitable formatting item is found.
	 */
	public FormattingItem getInsideFormatting(FormattingLocator locator) {
		ScannedFormattingItem item;
		if (locator.locator == Locator.START) {
			item = formattingList.ceiling(ScannedFormattingItem.getCompareItem(locator.line, locator.col));
			if (item == null)
				return FormattingItem.NO_FORMATTING;
			if (item.startLine == locator.line && item.startColumn == locator.col) {
				formattingList.remove(item);
				item = item.mergeItems(Adjacency.BACK, getBackAdjacentFormatting(item));
				return item;
			}
		} else {
			item = formattingList.floor(ScannedFormattingItem.getCompareItem(locator.line, locator.col));
			if (item == null)
				return FormattingItem.NO_FORMATTING;
			if (item.endLine == locator.line && item.endColumn == locator.col) {
				formattingList.remove(item);
				item = item.mergeItems(Adjacency.FRONT, getFrontAdjacentFormatting(item));
				return item;
			}
		}
		return FormattingItem.NO_FORMATTING;
	}

	/**
	 * Calculates back adjacent formatting for <code>node</code>.
	 * @param node node specifying position
	 * @return Back adjacent formatting, if found else NO_FORMATTING is returned.
	 */
	public FormattingItem getBackAdjacentFormatting(FormattingItem node) {
		if (!node.isScanned())
			return FormattingItem.NO_FORMATTING;
		ScannedFormattingItem sfi = (ScannedFormattingItem) node;
		ScannedFormattingItem item = formattingList.ceiling(ScannedFormattingItem.getCompareItem(sfi.endLine, sfi.endColumn));
		if (item == null)
			return FormattingItem.NO_FORMATTING;
		Adjacency adjacency = item.getAdjacency(node);
		if (adjacency == Adjacency.FRONT) {
			formattingList.remove(item);
			return item;
		}
		return FormattingItem.NO_FORMATTING;
	}
	
	/**
	 * Calculates back adjacent formatting for the symbol <code>node</code>.
	 * @param node node specifying position
	 * @return Bacl adjacent formatting, if found else NO_FORMATTING is returned.
	 */
	public FormattingItem getBackAdjacentFormatting(Symbol node) {
		ScannedFormattingItem item = formattingList.ceiling(ScannedFormattingItem.getEndCompareItem(node));
		if (item == null)
			return FormattingItem.NO_FORMATTING;
		RelativePosition relativePosition = item.getBackRelativePosition(node);
		if (relativePosition == RelativePosition.BACK_ADJACENT || relativePosition == RelativePosition.INSIDE) {
			formattingList.remove(item);
			return item;
		}
		return FormattingItem.NO_FORMATTING;
	}
	
	/*
	 * (non-Javadoc)
	 * @see java.lang.Iterable#iterator()
	 */
	@Override
	public Iterator<ScannedFormattingItem> iterator() {
		return formattingList.iterator();
	}

}