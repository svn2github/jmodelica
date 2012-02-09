package org.jmodelica.util;

/**
 * An empty <code>FormattingItem</code> used when there is no formatting.
 */
public class EmptyFormattingItem extends FormattingItem {

	/**
	 * Creates an <code>EmptyFormattingItem</code> to use when there is no formatting.
	 */
	public EmptyFormattingItem() {
		super(FormattingItem.Type.EMPTY, null, -1, -1, -1, -1);
	}

	@Override
	public String toString() {
		return "";
	}

}
