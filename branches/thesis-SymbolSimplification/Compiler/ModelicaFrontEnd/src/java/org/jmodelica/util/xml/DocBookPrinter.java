package org.jmodelica.util.xml;

import java.io.PrintStream;
import java.util.regex.Pattern;

public class DocBookPrinter extends XMLPrinter {
    private static final Pattern PREPARE_PAT = 
            Pattern.compile("(?<=^|[^-a-zA-Z_])('[a-z]+'|true|false|[a-z]+(_[a-z]+)+)(?=$|[^-a-zA-Z_])");
    
    public DocBookPrinter(PrintStream out, String indent) {
        super(out, indent, "  ");
    }
    
    public String lit(String str) {
        return surround(str, "literal");
    }
    
    public String prepare(String str) {
        return PREPARE_PAT.matcher(str).replaceAll("<literal>$1</literal>");
    }
}