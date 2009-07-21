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

package org.jmodelica.ide.indent;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.Document;
import org.jmodelica.ide.helpers.Util;


/**
 * Convenience class for indenting and handling indented sections of text.
 * 
 * @author philip
 * 
 */
public class IndentedSection {

public static int tabWidth = 4;
public static boolean tabbed = true;
public static String commentSyntax = "//";
public static String lineSep =
        System.getProperties().getProperty("line.separator", "\n");

protected final String[] sec;

/**
 * Creates a section of lines defined from <code>s</code> by splitting on line
 * separators.
 * @param s string to create section from
 * @param tabWidth tab width when converting to and from tabbed representation
 */
public IndentedSection(String s) {
    sec = s.split("\n|\r|\r\n", -1);
    for (int i = 0; i < sec.length; i++)
        sec[i] = tabbed ? tabify(sec[i]) : spacify(sec[i]);
}

/**
 * Indents source code in <code>source</code> according to indentation hints in
 * <code>hints</code>. Hint offsets need to be as in this.toString().
 * @param source source code to indent
 * @param hints hints to indent by
 * @return indented source code
 */
public IndentedSection indent(AnchorList<Integer> hints, int lineStart, int lineEnd) {

    Document d = new Document(toString());

    int[] indents = new int[sec.length];
    int[] adjusts = new int[sec.length];

    try { 
    for (int i = lineStart; i < lineEnd; i++) {

        int offset = d.getLineOffset(i);
        
        Anchor<Integer> a = hints.sinkAt(offset + sec[i].length());
        if (a == null || a.offset < offset)
            a = hints.anchorAt(offset);

        int indent = a.indent + adjusts[d.getLineOfOffset(a.reference)];  

        indents[i] = indent;
        adjusts[i] = indents[i] - countIndent(sec[i]);

    }

    for (int i = lineStart; i < lineEnd; i++) 
        if (!sec[i].trim().startsWith(commentSyntax))
            sec[i] = putIndent(sec[i], indents[i]);
    
    } catch (BadLocationException e) {}
    
    return this;
}

/**
 * @see IndentedSection#indent(AnchorList)
 */
public IndentedSection indent(AnchorList<Integer> hints) {
    return indent(hints, 0, sec.length);
}

public static boolean isIndentChar(char c) {
    return c == ' ' || c == '\t';
}

/**
 * Trim indentation
 * 
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
 * 
 * @param s String to count
 * @return
 */
public static int countIndent(String s) {
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
 * 
 * @param s String to change
 * @param Indentation width in spaces
 * @return
 */
public static String putIndent(String s, int count) {
    return putIndent(s, count, tabbed);
}

/**
 * Convert indent to tabs
 * 
 * @param s
 * @return
 */
public static String tabify(String s) {
    return putIndent(s, countIndent(s), true);
}

/**
 * Convert indent to spaces
 * 
 * @param s
 * @return
 */
public static String spacify(String s) {
    int col = 0;
    StringBuilder bob = new StringBuilder();
    for (char c : s.toCharArray()) {
        if (c == '\n' || c == '\r') {
            col = 0;
            bob.append(c);
        } else if (c == '\t') {
            int spaces = tabWidth - col % tabWidth;
            for (int i = 0; i < spaces; i++)
                bob.append(' ');
            col += spaces;
        } else {
            bob.append(c);
            col++;
        }
    }
    return bob.toString();
}

/**
 * Offset indentation in this section to <code>offset</code> spaces, for the
 * first line in the section. Keep relative indentations for whole section, if
 * possible.
 * 
 * @param offset offset
 */
public IndentedSection offsetIndentTo(int offset) {
    int ref = countIndent(sec[0]);
    for (int i = 0; i < sec.length; i++) {
        sec[i] = putIndent(sec[i], 
                Math.max(0, offset + countIndent(sec[i]) - ref));
    }
    if (sec[sec.length - 1].trim().equals(""))
        sec[sec.length - 1] = "";
    return this;
}

/**
 * Returns a string repr. of lines <code>start</code> to <code>end</code>.
 * @param startLine line start
 * @param endLine line end
 * @return string repr. of lines <code>start</code> to <code>end</code>
 */
public String toString(int startLine, int endLine) {
    String[] tmp = new String[endLine - startLine];
    for (int i = startLine; i < endLine; i++)
        tmp[i - startLine] = putIndent(sec[i], countIndent(sec[i]), tabbed);
    return Util.implode(lineSep, tmp);
}

public String toString() {
    return toString(0, sec.length);
}

}
