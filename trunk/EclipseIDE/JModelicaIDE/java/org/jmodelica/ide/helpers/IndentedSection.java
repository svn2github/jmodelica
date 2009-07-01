/*
Copyright (C) 2009 Modelon AB

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

package org.jmodelica.ide.helpers;

/**
 * Convenience class for handling indented sections of text
 * @author philip
 *
 */
public class IndentedSection {

	public static String lineSep = System.getProperties().getProperty("line.separator");
	public static int tabWidth = 4;
	public static boolean tabbed = true;
	
	protected final String[] sec;
	protected final    int[] ind;
	
	/**
	 * Creates a section of lines defined from <code>s</code> by
	 * splitting on line separators. 
	 * @param s string to create section from
	 * @param tabWidth tab width when converting to and from tabbed
	 * representation
	 */
	public IndentedSection(String s) {
		
		sec = s.split("\n|\r|\r\n", -1);
		ind = new int[sec.length];
		
		for (int i = 0; i < sec.length; i++) {
			sec[i] = spacify(sec[i]);
			ind[i] = getIndent(sec[i]);
		}
	}

	public static boolean isIndentChar(char c) {
		return c == ' ' || c == '\t';
	}
	
	/**
	 * Trim indentation
	 * @param s string to trim
	 * @return
	 */
	public static String trimIndent(String s) {
		int i = 0;
		while (i < s.length() && isIndentChar(s.charAt(i)))
			++i;
		return s.substring(i);
	}
	
	/**
	 * Count indentation width
	 * @param s String to count
	 * @return
	 */
	public static int getIndent(String s) {
		s = spacify(s);
		int i = 0; 
		while (i < s.length() && s.charAt(i) == ' ')
			i++;
		return i;
	}

	protected static String putIndent(String s, int count, boolean tabbed) {
		StringBuilder bob = new StringBuilder();
		while (tabbed && count - tabWidth >= 0) {
			bob.append('\t');
			count -= tabWidth;
		}	
		while (count - 1 >= 0) {
			bob.append(' ');
			count--;
		}
		return bob.toString() + trimIndent(s);
	}

	/**
	 * Set indentation width
	 * @param s String to change
	 * @param Indentation width in spaces
	 * @return
	 */
	public static String putIndent(String s, int count) {
		return putIndent(s, count, tabbed); 
	}
		
	/**
	 * Convert indent to tabs
	 * @param s
	 * @return
	 */
	public static String tabify(String s) {
		return putIndent(s, getIndent(s), true);
	}
	
	/**
	 * Convert indent to spaces
	 * @param s
	 * @return
	 */
	public static String spacify(String s) {
		StringBuilder bob = new StringBuilder();
		for (char c : s.toCharArray()) {
			if (c == '\t') {
				int spaces = tabWidth - bob.length() % tabWidth;
				for (int i = 0; i < spaces; i++) 
					bob.append(' ');
			} else 
				bob.append(c);
		}	
		return bob.toString();
	}
		
	/**
	 * Offset indentation in this section to <code>offset</code> spaces, for the
	 * first line in the section. Keep relative indentations for whole section,
	 * if possible. 
	 * @param offset offset 
	 */
	public IndentedSection offsetIndentTo(int offset) {
		int ref = getIndent(sec[0]);
		for (int i = 0; i < sec.length; i++) {
			sec[i] = putIndent(sec[i], 
					Math.max(0, offset + getIndent(sec[i]) - ref));
		}
		if (sec[sec.length-1].trim().equals(""))
			sec[sec.length-1] = "";
		return this;
	}
	
	public String toString() {
		String[] tmp = new String[sec.length];
		for (int i = 0; i < sec.length; i++) 
			tmp[i] = tabify(sec[i]);
		return Util.implode(lineSep, tmp);
	}
}
