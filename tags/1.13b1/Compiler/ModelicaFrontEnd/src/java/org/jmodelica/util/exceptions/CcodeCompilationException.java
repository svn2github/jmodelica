package org.jmodelica.util.exceptions;

/**
 * Thrown by the compiler when failing to compile a binary file from c code.
 */
@SuppressWarnings("serial")
public class CcodeCompilationException extends RuntimeException {

    public CcodeCompilationException() {
    }

    public CcodeCompilationException(String msg) {
        super(msg);
    }

}
