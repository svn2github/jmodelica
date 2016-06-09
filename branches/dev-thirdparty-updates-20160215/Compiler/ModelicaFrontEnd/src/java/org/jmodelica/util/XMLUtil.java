/*
    Copyright (C) 2016 Modelon AB

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
package org.jmodelica.util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class XMLUtil {

    private XMLUtil() {}

    private static Pattern escapePattern = Pattern.compile("[\"&'<>\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F]");

    public static String escape(String message) {
        if (message == null)
            return message;
        Matcher matcher = escapePattern.matcher(message);
        StringBuffer sb = new StringBuffer();
        while (matcher.find()) {
            String replacement;
            String group = matcher.group();
            if (group.length() != 1) {
                throw new IllegalArgumentException("Expecting a match group of length 1, got " + group.length() + "!");
            }
            char c = group.charAt(0);
            if (c == '"') {
                replacement = "&quot;";
            } else if (c == '&') {
                replacement = "&amp;";
            } else if (c ==  '\'') {
                replacement = "&apos;";
            } else if (c == '<') {
                replacement = "&lt;";
            } else if (c == '>') {
                replacement = "&gt;";
            } else if ((c >= 0x0 && c <= 0x8) || (c >= 0xB && c <= 0xC) || (c >= 0xE && c <= 0x1F)) {
                replacement = ""; // These characters aren't allowed by the XML specification
            } else {
                throw new IllegalArgumentException("Unsupported treated characther number " + Character.getNumericValue(c) + "!");
            }
            matcher.appendReplacement(sb, replacement);
        }
        matcher.appendTail(sb);
        return sb.toString();
    }

    public static String[] escape(String... messages) {
        String[] escaped = new String[messages.length];
        for (int i = 0; i < messages.length; i++)
            escaped[i] = escape(messages[i].toString());
        return escaped;
    }

}
