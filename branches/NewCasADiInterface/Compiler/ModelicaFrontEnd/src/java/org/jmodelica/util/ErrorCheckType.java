package org.jmodelica.util;

public enum ErrorCheckType {
    COMPILE (false), 
    CHECK   (true);
    
    public final boolean allowOuterWithoutInner;

    private ErrorCheckType(boolean allowOuterWithoutInner) {
        this.allowOuterWithoutInner = allowOuterWithoutInner;
    }

}
