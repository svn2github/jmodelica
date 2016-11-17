package org.jmodelica.util.streams;

import java.io.IOException;
import java.io.PrintStream;
import java.util.ArrayList;

public class ConditionalCodeStream extends CodeStream {
    private CodeStream str;
    private boolean hasPrinted = false;
    private boolean bufferMode = false;
    private ArrayList<String> buf = new ArrayList<String>();
    
    public ConditionalCodeStream(CodeStream str) {
        super((PrintStream)null);
        this.str = str;
    }
    
    @Override
    public void close() {
        clear();
        buf = null;
    }
    
    @Override
    public void print(String s) {
        if (bufferMode) {
            buf.add(s);
        } else {
            hasPrinted = true;
            clear();
            str.print(s);
        }
    }
    
    public void setBufferMode(boolean bufferMode) {
        this.bufferMode = bufferMode;
    }
    
    public void reset() {
        hasPrinted = false;
    }
    
    public void clear() {
        if (hasPrinted) {
            for (String sb : buf) {
                str.print(sb);
            }
            buf.clear();
        }
    }
}
