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
