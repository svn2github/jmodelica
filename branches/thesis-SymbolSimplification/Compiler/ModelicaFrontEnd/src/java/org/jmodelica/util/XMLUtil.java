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
package org.jmodelica.util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class XMLUtil {
	private XMLUtil() {
	}
	
	private static Pattern escapePattern = Pattern.compile("[\"&'<>]");
	public static String escape(String message) {
		if (message == null)
			return message;
		Matcher matcher = escapePattern.matcher(message);
		StringBuffer sb = new StringBuffer();
		while (matcher.find()) {
			String replacement;
			if ("\"".equals(matcher.group()))
				replacement = "&quot;";
			else if ("&".equals(matcher.group()))
				replacement = "&amp;";
			else if ("'".equals(matcher.group()))
				replacement = "&apos;";
			else if ("<".equals(matcher.group()))
				replacement = "&lt;";
			else if (">".equals(matcher.group()))
				replacement = "&gt;";
			else
				throw new IllegalArgumentException();
			matcher.appendReplacement(sb, replacement);
		}
		matcher.appendTail(sb);
		return sb.toString();
	}
	
	public static String[] escape(String ... messages) {
		String[] escaped = new String[messages.length];
		for (int i = 0; i < messages.length; i++)
			escaped[i] = escape(messages[i].toString());
		return escaped;
	}
	
}
