package org.jmodelica.util.exceptions;

public class InternalCompilerError extends ModelicaException {

    /**
     * 
     */
    private static final long serialVersionUID = -7205166607273956113L;

    public InternalCompilerError(String msg, Exception cause) {
        super(msg, cause);
    }
}
