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
		if (where == Adjacency.NONE || otherItem.isEmptyDefault()) {
			return this;
		} else if (otherItem.isScanned()) {
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
			if (currentChar == ' ' || currentChar == '\t' || currentChar == '\f') {
				dataBuilder.append(data.charAt(i));
			} else if  (currentChar == '\n' || currentChar == '\r') {
				dataBuilder = new StringBuilder();
			}
		}
		
		return new DefaultFormattingItem(dataBuilder.toString());
	}
	
	@Override
	public final boolean isScanned() {
		return false;
	}
	
	@Override
	public final boolean isScannedMixed() {
		return false;
	}
	
	@Override
	public boolean isEmptyDefault() {
		return false;
	}
	
	@Override
	public FormattingItem combineItems(ScannedFormattingItem otherItem) {
		throw new RuntimeException("This method has not been implemented for DefaultFormattingItem.");
	}
	
	@Override
	public int spanningLines() {
		int numberOfLines = 0;
		for (int i = 0; i < data.length(); i++) {
			switch (data.charAt(i)) {
			case '\r':
				if (i + 1 < data.length() && data.charAt(i + 1) == '\n') {
					++i;
				}
			case '\n':
				if (i + 1 < data.length()) {
					++numberOfLines;
				}
				break;
			default:
				break;
			}
		}

		return numberOfLines;
	}

	@Override
	public int spanningColumnsOnLastLine() {
		int columns = 0;
		for (int i = data.length() - 1; i >= 0; i--) {
			if (data.charAt(i) != '\r' && data.charAt(i) != '\n') {
				++columns;
			} else {
				return columns;
			}
		}
		
		return columns;
	}
	
	@Override
	public boolean inside(int line, int column) {
		int endLine = 1 + spanningLines();
		int endColumn = spanningColumnsOnLastLine();

		return (line > 1 || (line == 1 && column >= 1)) &&
				(line < endLine || (line == endLine && column <= endColumn));
	}

	@Override
	public void offsetItemAfter(int line, int column, int byLines, int byColumnsOnLastLine) {
		return;
	}
}
