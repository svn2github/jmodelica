package org.jmodelica.util.exceptions;


@SuppressWarnings("serial")
public class IndexReductionException extends ModelicaException {
    public IndexReductionException() {
        this("");
    }
    public IndexReductionException(String message) {
        super("Index reduction failed" + (message.isEmpty() ? "" : ": " + message));
    }
}
