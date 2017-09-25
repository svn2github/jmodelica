package org.jmodelica.util.xml;

import java.io.File;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintStream;
import java.io.StringWriter;
import java.io.Writer;
import java.util.Collection;
import java.util.Map;

/**
 * Utility methods for strings.
 */
public final class StringUtil {
    
    /**
     * Hidden default constructor to prevent instantiation.
     */
    private StringUtil() {}

    private static void doWrap(Writer out, String text, String prefix, String partSep, String suffix, char splitAt,
            int width) {
        try {
            if (width == 0) {
                width = Integer.MAX_VALUE;
            }
            int start = 0;
            int end = width;
            int len = text.length();
            while (end < len) {
                while (end > start && text.charAt(end) != splitAt)
                    end--;
                out.append(prefix);
                if (end <= start) {
                    out.append(text.substring(start, start + width - 1));
                    start += width - 1;
                    out.append('-');
                } else {
                    out.append(text.substring(start, end + 1));
                    start = end + 1;
                }
                out.append(suffix);
                out.append(partSep);
                end = start + width;
            }
            out.append(prefix);
            out.append(text.substring(start));
            out.append(suffix);
        } catch (IOException e) {}
    }

    public static void wrapText(PrintStream out, String text, String indent, int width) {
        OutputStreamWriter osw = new OutputStreamWriter(out);
        doWrap(osw, text, indent, "", "\n", ' ', width);
        try {
            osw.flush();
        } catch (IOException e) {
            // Not much to do here!
        }
    }

    public static String wrapUnderscoreName(String text, int width) {
        StringWriter out = new StringWriter();
        doWrap(out, text, "", " ", "", '_', width);
        return out.toString();
    }

    /**
     * Trims a string and replaces all whitespace occurrences with singular
     * spaces.
     * 
     * @param text  the text to "conform."
     * @return      {@code text}, trimmed, with all remaining white spaces replaced by singular spaces.
     */
    public static String conformWhiteSpace(String text) {
        return text.trim().replaceAll("\\s+", " ");
    }

    /**
     * Joins together a collection of strings, separating them by a delimiter.
     * 
     * @param delimiter the delimiter.
     * @param args      the strings to join.
     * @return          all strings in {@code args}, delimited by {@code delimiter}.
     */
    public static String join(String delimiter, Collection<String> args) {
        return join(delimiter, args.toArray(new String[args.size()]));
    }

    /**
     * Joins together a collection of strings, separating them by a delimiter.
     * 
     * @param delimiter the delimiter.
     * @param args      the strings to join.
     * @return          all strings in {@code args}, delimited by {@code delimiter}.
     */
    public static String join(String delimiter, String... args) {
        StringBuilder sb = new StringBuilder();
        boolean first = true;
        for (String str : args) {
            if (!first)
                sb.append(delimiter);
            first = false;
            sb.append(str);
        }
        return sb.toString();
    }

    /**
     * Joins together a collection of string pairs, separating pairs by a delimiter, and pair members by
     * another delimiter.
     * 
     * @param delimiter     the delimiter to separate pairs.
     * @param pairDelimiter the delimiter to separate pair members.
     * @param args          the pairs.
     * @return              all string pairs in {@code args}, delimited by {@code delimiter} and {@code pairDelimiter}.
     */
    public static String join(String delimiter, String pairDelimiter, Map<String, String> args) {
        StringBuilder sb = new StringBuilder();
        boolean first = true;
        for (Map.Entry<String, String> pair : args.entrySet()) {
            if (!first) {
                sb.append(delimiter);
            }
            first = false;
            sb.append(pair.getKey());
            sb.append(pairDelimiter);
            sb.append(pair.getValue());
        }
        return sb.toString();
    }

    /**
     * Joins together a collection of strings into a path.
     * <p>
     * Calls {@link #join(String, String...)} with the first argument as {@link File#separator}.
     * 
     * @param args  the strings to join.
     * @return      all strings in {@code args}, delimited by {@link File#separator}.
     */
    public static String joinPath(String... args) {
        return join(File.separator, args);
    }
}
