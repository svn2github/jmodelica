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
package org.jmodelica.util;

import java.io.File;

import org.jmodelica.util.logging.Level;
import org.jmodelica.util.logging.XMLLogger;
import org.jmodelica.util.logging.units.LoggingUnit;

/**
 * Contains information about the generated result of the compilation.
 */
public class CompiledUnit implements LoggingUnit {

    private static final long serialVersionUID = -4515905183271933348L;

    private File file;

    public CompiledUnit(File file) {
        this.file = file;
    }

    /**
     * Get the file object pointing to the generated file.
     */
    public File getFile() {
        return file;
    }

    @Override
    public String toString() {
        return file.toString();
    }

    @Override
    public String print(Level level) {
        return "";
    }

    @Override
    public String printXML(Level level) {
        return XMLLogger.write_node("CompilationUnit", "file", toString());
    }

    @Override
    public void prepareForSerialization() {
    }

}
