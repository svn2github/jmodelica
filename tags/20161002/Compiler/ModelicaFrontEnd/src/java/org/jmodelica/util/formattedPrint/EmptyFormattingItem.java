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
 * An empty <code>FormattingItem</code> used when there is no formatting.
 */
public class EmptyFormattingItem extends DefaultFormattingItem {

	/**
	 * Creates an <code>EmptyFormattingItem</code> to use when there is no formatting.
	 */
	public EmptyFormattingItem() {
		super(Type.EMPTY, null);
	}

	@Override
	public FormattingItem mergeItems(Adjacency where, FormattingItem otherItem) {
		if (!otherItem.isEmptyDefault()) {
			return otherItem;
		}

		return this;
	}

	@Override
	public String toString() {
		return "";
	}

	@Override
	public DefaultFormattingItem copyWhitepacesFromFormatting() {
		return new EmptyFormattingItem();
	}
	
	@Override
	public final boolean isEmptyDefault() {
		return true;
	}
}
