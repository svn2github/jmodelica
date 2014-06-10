package org.jmodelica.util.exceptions;

public class IndexReductionException extends ModelicaException {
    private static final long serialVersionUID = 1;

    public IndexReductionException() {
        this("");
    }

    public IndexReductionException(String message) {
        super("Index reduction failed" + (message.isEmpty() ? "" : ": " + message));
    }
}
