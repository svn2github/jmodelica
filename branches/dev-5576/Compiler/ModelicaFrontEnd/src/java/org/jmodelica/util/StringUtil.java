package org.jmodelica.util;

import java.io.File;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintStream;
import java.io.StringWriter;
import java.io.Writer;
import java.util.Arrays;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

import org.jmodelica.util.collections.TransformerIterable;

public final class StringUtil {
    /**
     * Hidden default constructor to prevent instantiation.
     */
    private StringUtil() {
    }

    /*=========================================================================
     *     Wrapping, TODO: we need to document these better!
     *========================================================================*/
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

    /*=========================================================================
     *     Joining
     *========================================================================*/
    /**
     * Joins together a collection of strings, separating them by a delimiter.
     * 
     * @param delimiter the delimiter.
     * @param args      the strings to join.
     * @return          all strings in {@code args}, delimited by {@code delimiter}.
     */
    public static String join(String delimiter, String... args) {
        return join(Arrays.asList(args), delimiter);
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
    public static String join(String delimiter, final String pairDelimiter, Map<String, String> args) {
        Iterable<String> transformed = new TransformerIterable<Map.Entry<String, String>, String>(args.entrySet()) {
            @Override
            protected String transform(Entry<String, String> entry) throws SkipException {
                return entry.getKey() + pairDelimiter + entry.getValue();
            }
        };
        return join(transformed, delimiter);
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

    /**
     * Same as calling {@link #join(Iterable, String, String, String)} with
     * ", " as separator, " and " as lastSeparator and "<empty>" as
     * emptyString.
     */
    public static <T> String humanJoin(Iterable<T> iterable) {
        return join(iterable, ", ", " and ", "<empty>");
    }

    /**
     * Same as calling {@link #join(Iterable, String, String, String)} with 
     * lastSeparator equal to separator and "" as emptyString.
     */
    public static <T> String join(Iterable<T> iterable, String separator) {
        return join(iterable.iterator(), separator, separator, "");
    }

    /**
     * Similar to {@link #join(Iterator, String, String, String)}, see for more info.
     */
    public static <T> String join(Iterable<T> iterable, String separator, String lastSeparator, String emptyString) {
        return join(iterable.iterator(), separator, lastSeparator, emptyString);
    }

    /**
     * Utility method for printing a list of elements in a nice way. This 
     * method takes an iterator with objects, a separator, a separator to use
     * between the second to last and last object, and a string which
     * represents an empty string. The return value is then produced by
     * concatenating all the objects in the iterator with the separator in
     * between each object. If there is no objects in the iterator, then
     * the emptyString is written instead.
     * 
     * @param iterator Iterator with objects
     * @param separator Separator string to use
     * @param lastSeparator The separator to use for the last element
     * @param emptyString String to print if there are no objects
     * @return A concatenated string
     */
    public static <T> String join(Iterator<T> iterator, String separator, String lastSeparator, String emptyString) {
        StringBuilder sb = new StringBuilder();
        boolean first = true;
        while (iterator.hasNext()) {
            Object element = iterator.next();
            if (!first) {
                if (iterator.hasNext()) {
                    sb.append(separator);
                } else {
                    sb.append(lastSeparator);
                }
            }
            first = false;
            sb.append(element);
        }
        if (first) {
            sb.append(emptyString);
        }
        return sb.toString();
    }

    /*=========================================================================
     *     Other, group into categories when you find a pattern among these!
     *========================================================================*/
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

}
