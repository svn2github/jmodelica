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
package org.jmodelica.util.streams;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.OutputStream;
import java.io.PrintStream;

public class CodeStream {
    private PrintStream out;
    
    public CodeStream(PrintStream ps) {
        this.out = ps;
    }
    
    public CodeStream(OutputStream os) {
        this.out = new PrintStream(os);
    }
    
    public CodeStream(File file) throws FileNotFoundException {
        this.out = new PrintStream(file);
    }
    
    public CodeStream(String file) throws FileNotFoundException {
        this.out = new PrintStream(file);
    }
    
    public CodeStream(CodeStream str) {
        this(str.out);
    }
    
    public void close() {
        out.close();
        out = null;
    }
    
    public void println() {
        print("\n");
    }
    
    public void print(String s) {
        out.print(s);
    }
    
    public void print(Object o) {
        print(o.toString());
    }
    
    public void println(String s) {
        print(s);
        println();
    }
    
    public void println(Object o) {
        print(o);
        println();
    }
    
    public void format(String format, Object... args) {
        print(String.format(format, args));
    }
    
    public void formatln(String format, Object... args) {
        println(String.format(format, args));
    }
}