package org.jmodelica.util;

/**
 * An object that is used to set some sort of default formatting, which has not come from a scanned text and
 * therefore has no original position.
 */
public class DefaultFormattingItem extends FormattingItem {
	/**
	 * Creates a <code>DefaultFormattingItem</code>
	 * @param type the type of this item.
	 * @param data the string representation of what this item holds, such as a white space.
	 */
	protected DefaultFormattingItem(Type type, String data) {
		super(type, data);
	}

	/**
	 * Creates a <code>DefaultFormattingItem</code>
	 * @param data the string representation of what this item holds, such as a white space.
	 */
	public DefaultFormattingItem(String data) {
		super(Type.DEFAULT, data);
	}

	@Override
	public Adjacency getAdjacency(FormattingItem otherItem) {
		return Adjacency.NONE;
	}

	@Override
	public FormattingItem mergeItems(Adjacency where, FormattingItem otherItem) {
		if (where == Adjacency.NONE || otherItem instanceof EmptyFormattingItem) {
			return this;
		} else if (otherItem instanceof ScannedFormattingItem) {
			return otherItem;
		}
		
		if (where == Adjacency.FRONT) {
			this.data = otherItem.data + this.data;
		} else {
			this.data = this.data + otherItem.data;
		}

		return this;
	}
	
	@Override
	public RelativePosition getFrontRelativePosition(int line, int column) {
		return RelativePosition.UNDEFINED;
	}
	
	@Override
	public RelativePosition getBackRelativePosition(int line, int column) {
		return RelativePosition.UNDEFINED;
	}
	
	@Override
	public DefaultFormattingItem copyWhitepacesFromFormatting() {
		StringBuilder dataBuilder = new StringBuilder();
		for (int i = 0; i < data.length(); i++) {
			char currentChar = data.charAt(i);
			if (currentChar == ' ' || currentChar == '\t' || currentChar == '\f' || currentChar == '\n' || currentChar == '\r') {
				dataBuilder.append(data.charAt(i));
			}
		}
		
		return new DefaultFormattingItem(dataBuilder.toString());
	}
}
