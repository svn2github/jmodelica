package org.jmodelica.util;

public class TruncatedCodeStream extends CodeStream {
    int limit;
    boolean first = true;
    String beginString = "(truncated)";
    String endString = "...";
    StringBuilder buffer;
    
    public TruncatedCodeStream(CodeStream str) {
        this(str, 509);
    }
    
    public TruncatedCodeStream(CodeStream str, int lim) {
        super(str);
        this.limit = lim - endString.length() - beginString.length();
        buffer = new StringBuilder();
    }
    
    public void print(String s) {
        int l = buffer.length();
        if (l < limit) {
            boolean end = l + s.length() > limit;
            if (end) {
                s = s.substring(0, limit - l);
            }
            buffer.append(s);
        }
    }
    
    public void close() {
        boolean trunc = buffer.length() >= limit;
        if (trunc)
            super.print(beginString);
        super.print(buffer.toString());
        if (trunc)
            super.print(endString);
    }
}