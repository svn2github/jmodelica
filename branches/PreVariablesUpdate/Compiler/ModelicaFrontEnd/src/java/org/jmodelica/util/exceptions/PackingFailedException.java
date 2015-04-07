package org.jmodelica.util.exceptions;

/**
 * Thrown by the compiler fails pack the compiled model
 */
public class PackingFailedException extends ModelicaException {
    private static final long serialVersionUID = 1;

    public PackingFailedException() {}

    public PackingFailedException(String msg) {
        super(msg);
    }

}
