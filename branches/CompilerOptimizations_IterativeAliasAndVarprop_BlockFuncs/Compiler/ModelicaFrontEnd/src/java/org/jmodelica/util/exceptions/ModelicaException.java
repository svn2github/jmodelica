package org.jmodelica.util.exceptions;

/**
 * Common super class for all JModelica exceptions.
 */

public class ModelicaException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public ModelicaException() {}

    public ModelicaException(String message) {
        super(message);
    }

    public ModelicaException(String message, Throwable cause) {
        super(message, cause);
    }
}
