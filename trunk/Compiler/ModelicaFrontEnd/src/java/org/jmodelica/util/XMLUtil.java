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
