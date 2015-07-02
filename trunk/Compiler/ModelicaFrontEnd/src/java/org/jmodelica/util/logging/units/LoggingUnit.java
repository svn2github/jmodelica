package org.jmodelica.util.logging.units;

import java.io.Serializable;

import org.jmodelica.util.logging.Level;

public interface LoggingUnit extends Serializable {
    public String print(Level level);
    public String printXML(Level level);
    public void prepareForSerialization();
}
