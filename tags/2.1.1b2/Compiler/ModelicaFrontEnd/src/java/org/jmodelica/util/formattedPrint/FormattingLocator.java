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

public class FormattingLocator {
	
	public enum Locator {
		START,
		END,
	}
	
	public final Locator locator;
	public final int line;
	public final int col;

	public FormattingLocator(Locator locator, int line, int col) {
		this.locator = locator;
		this.line = line;
		this.col = col;
	}
	
}
