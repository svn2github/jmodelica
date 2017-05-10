/*
    Copyright (C) 2016 Modelon AB

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
import java.io.PrintStream;

public class SplitFilesCodeStream extends CodeStream {
    private File file;
    private boolean debugGen;
    private int i = 0;
    private String header;
    private CodeStream str;
    
    public SplitFilesCodeStream(File file, boolean debugGen, String header) {
        super((PrintStream)null);
        this.file = file;
        this.debugGen = debugGen;
        this.header = header;
        str = nextFileStream();
    }
    
    public void print(String s) {
        str.print(s);
    }
    
    public void close() {
        str.close();
        str = null;
    }
    
    public void splitFile() {
        close();
        str = nextFileStream();
        print(header);
    }
    
    private CodeStream nextFileStream() {
        String path = file.getPath();
        if (i > 0) {
            path = path.replace(".c", "_" + i + ".c");
        }
        i++;
        return new NotNullCodeStream(createPrintStream(new File(path), debugGen));
    }

}
