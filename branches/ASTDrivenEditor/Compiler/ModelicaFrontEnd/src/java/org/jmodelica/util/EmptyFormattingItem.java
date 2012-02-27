package org.jmodelica.util;

import org.jmodelica.util.FormattingItem.Adjacency;

/**
 * An empty <code>FormattingItem</code> used when there is no formatting.
 */
public class EmptyFormattingItem extends DefaultFormattingItem {

	/**
	 * Creates an <code>EmptyFormattingItem</code> to use when there is no formatting.
	 */
	public EmptyFormattingItem() {
		super(FormattingItem.Type.EMPTY, null);
	}
	
	public FormattingItem mergeItems(Adjacency where, FormattingItem otherItem) {
		if (otherItem.getType() != Type.EMPTY) {
			return otherItem;
		}

		return this;
	}

	@Override
	public String toString() {
		return "";
	}

}
