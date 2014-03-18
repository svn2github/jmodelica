package org.jmodelica.util.exceptions;

/**
 * Thrown by the compiler when failing to compile a binary file from c code.
 */
public class CcodeCompilationException extends RuntimeException {

    private static final long serialVersionUID = 1;

    public CcodeCompilationException() {}

    public CcodeCompilationException(String msg) {
        super(msg);
    }

}
