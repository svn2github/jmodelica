package org.jmodelica.separateProcess;

public class SeparateProcessException extends Exception {
    private static final long serialVersionUID = 1;
    
    public SeparateProcessException(String message) {
        super(message);
    }

    public SeparateProcessException(String message, Throwable underlyingException) {
        super(message, underlyingException);
    }
    
}
