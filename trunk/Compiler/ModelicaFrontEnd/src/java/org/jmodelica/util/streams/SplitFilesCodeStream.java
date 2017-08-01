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
    
    public SplitFilesCodeStream(File file, boolean debugGen, String header) {
        super((CodeStream) null);
        this.file = file;
        this.debugGen = debugGen;
        this.header = header;
        switchParent(nextFileStream());
    }
    
    public void splitFile() {
        switchParent(nextFileStream());
        print(header);
    }
    
    protected CodeStream nextFileStream() {
        return createCodeStream(nextFile());
    }

    protected File nextFile() {
        String path = file.getPath();
        if (i > 0) {
            path = path.replaceAll(".[^.]+$", "_" + i + "$0");
        }
        i++;
        return new File(path);
    }

    protected NotNullCodeStream createCodeStream(File nextFile) {
        return new NotNullCodeStream(createPrintStream(nextFile, debugGen));
    }

}
