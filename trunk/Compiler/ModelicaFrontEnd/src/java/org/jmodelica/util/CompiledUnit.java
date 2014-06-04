package org.jmodelica.util;

import java.io.File;

/**
 * Contains information about the generated result of the compilation.
 */
public class CompiledUnit {

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

    public String toString() {
        return file.toString();
    }

}
