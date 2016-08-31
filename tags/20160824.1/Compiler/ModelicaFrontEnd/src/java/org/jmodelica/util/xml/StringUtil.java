package org.jmodelica.util.xml;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintStream;
import java.io.StringWriter;
import java.io.Writer;

public abstract class StringUtil {
    private static void doWrap(Writer out, String text, String prefix, String partSep, String suffix, char splitAt, int width) {
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
        } catch (IOException e) {
        }
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
        doWrap(out , text, "", " ", "", '_', width);
        return out.toString();
    }

}
