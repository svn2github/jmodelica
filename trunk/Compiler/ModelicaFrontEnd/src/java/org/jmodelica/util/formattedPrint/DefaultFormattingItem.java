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
}
