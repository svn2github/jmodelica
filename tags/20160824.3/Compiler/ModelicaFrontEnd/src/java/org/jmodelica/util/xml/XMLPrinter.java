package org.jmodelica.util.xml;

import java.io.PrintStream;
import java.util.Stack;

public class XMLPrinter {
    private Stack<XMLPrinter.Entry> stack;
    private String indent;
    private PrintStream out;
    private String indentStep;
    
    public XMLPrinter(PrintStream out, String indent, String indentStep) {
        stack = new Stack<XMLPrinter.Entry>();
        this.indent = indent;
        this.out = out;
        this.indentStep = indentStep;
    }
    
    public void enter(String name, Object... args) {
        stack.push(new Entry(indent, name));
        printHead(name, args);
        out.println('>');
        indent = indent + indentStep;
    }
    
    public void exit(int n) {
        for (int i = 0; i < n; i++) {
            exit();
        }
    }
    
    public void exit() {
        XMLPrinter.Entry e = stack.pop();
        indent = e.indent;
        out.format("%s</%s>\n", indent, e.name);
    }
    
    public void single(String name, Object... args) {
        printHead(name, args);
        out.print(" />\n");
    }
    
    public void oneLine(String name, String cont, Object... args) {
        printHead(name, args);
        out.format(">%s</%s>\n", cont, name);
    }

    public void text(String text, int width) {
        StringUtil.wrapText(out, text, indent, width);
    }
    
    public String surround(String str, String tag) {
        return String.format("<%s>%s</%s>", tag, str, tag);
    }
    
    private void printHead(String name, Object... args) {
        out.format("%s<%s", indent, name);
        for (int i = 0; i < args.length - 1; i += 2) {
            out.format(" %s=\"%s\"", args[i], args[i + 1]);
        }
    }
    
    private static class Entry {
        public final String indent;
        public final String name;
        
        private Entry(String indent, String name) {
            this.indent = indent;
            this.name = name;
        }
    }
}