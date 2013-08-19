package org.jmodelica.util;

/**
 * Common super class for all JModelica exceptions.
 */
  
@SuppressWarnings("serial")
public class ModelicaException extends Exception {
    
    public ModelicaException() {
    }
    
    public ModelicaException(String message) {
        super(message);
    }
    
    public ModelicaException(String message, Throwable cause) {
        super(message, cause);
    }
}
