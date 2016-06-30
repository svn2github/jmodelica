package org.jmodelica.util.exceptions;

public class InternalCompilerError extends ModelicaException {

    /**
     * 
     */
    private static final long serialVersionUID = -7205166607273956114L;

    public InternalCompilerError(String msg) {
        super(msg);
    }
    
    public InternalCompilerError(String msg, Exception cause) {
        super(msg, cause);
    }
}
