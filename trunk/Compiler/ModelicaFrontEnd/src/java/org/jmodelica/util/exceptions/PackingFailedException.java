package org.jmodelica.util.exceptions;

/**
 * Thrown by the compiler fails pack the compiled model
 */
@SuppressWarnings("serial")
public class PackingFailedException extends ModelicaException {

    public PackingFailedException() {
    }


    public PackingFailedException(String msg) {
        super(msg);
    }

}
