package org.jmodelica.ide.helpers;

/**
 * Convenience class for handling indented sections of text
 * @author philip
 *
 */
public class IndentedSection {

	protected final String[] sec;
	protected final    int[] ind;
	protected int tabWidth;

	/**
	 * Creates a section of lines defined from <code>s</code> by
	 * splitting on line separators. 
	 * @param s string to create section from
	 * @param tabWidth tab width when converting to and from tabbed
	 * representation
	 */
	public IndentedSection(String s, int tabWidth) {
		
		this.tabWidth = tabWidth;
		
		sec = s.split("\n|\r|\r\n", -1);
		ind = new int[sec.length];
		
		for (int i = 0; i < sec.length; i++) {
			sec[i] = spacify(sec[i]);
			ind[i] = getIndent(sec[i]);
		}
	}

	/**
	 * Count indentation width
	 * @param s String to count
	 * @return
	 */
	public int getIndent(String s) {
		s = spacify(s);
		int i = 0; 
		while (i < s.length() && s.charAt(i) == ' ')
			i++;
		return i;
	}

	/**
	 * Set indentation width
	 * @param s String to change
	 * @param Indentation width in spaces
	 * @param tabbed put tabs
	 * @return
	 */
	public String putIndent(String s, int count, boolean tabbed) {
		StringBuilder bob = new StringBuilder();
		while (tabbed && count - tabWidth >= 0) {
			bob.append('\t');
			count -= tabWidth;
		}	
		while (count - 1 >= 0) {
			bob.append(' ');
			count--;
		}
		return bob.toString() + s.trim();
	}

	/**
	 * Convert indent to tabs
	 * @param s
	 * @return
	 */
	public String tabify(String s) {
		return putIndent(s, getIndent(s), true);
	}
	
	/**
	 * Convert indent to spaces
	 * @param s
	 * @return
	 */
	public String spacify(String s) {
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
	public void offsetIndentTo(int offset) {
		int ref = getIndent(sec[0]);
		for (int i = 0; i < sec.length; i++)
			sec[i] = putIndent(sec[i], Math.max(0, offset + (getIndent(sec[i]) - ref)), false);
	}
	
	public String toString() {
		String[] tmp = new String[sec.length];
		for (int i = 0; i < sec.length; i++) 
			tmp[i] = tabify(sec[i]);
		String lineSep = System.getProperties().getProperty("line.separator");
		return Util.implode(lineSep, tmp);
	}
}
