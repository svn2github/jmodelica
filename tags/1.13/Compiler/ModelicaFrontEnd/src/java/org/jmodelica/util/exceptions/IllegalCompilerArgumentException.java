package org.jmodelica.util.exceptions;

/**
 * Exception caused by illegal target or version to the compiler.
 */
  
@SuppressWarnings("serial")
public class IllegalCompilerArgumentException extends ModelicaException {
    
    public IllegalCompilerArgumentException() {
    }
    
    public IllegalCompilerArgumentException(String message) {
        super(message);
    }
    
    public IllegalCompilerArgumentException(String message, Throwable cause) {
        super(message, cause);
    }
}
