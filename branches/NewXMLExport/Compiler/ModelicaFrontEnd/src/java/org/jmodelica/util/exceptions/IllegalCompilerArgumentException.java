package org.jmodelica.util.exceptions;

/**
 * Exception caused by illegal target or version to the compiler.
 */

public class IllegalCompilerArgumentException extends ModelicaException {

    private static final long serialVersionUID = 1;

    public IllegalCompilerArgumentException() {}

    public IllegalCompilerArgumentException(String message) {
        super(message);
    }

    public IllegalCompilerArgumentException(String message, Throwable cause) {
        super(message, cause);
    }
}
