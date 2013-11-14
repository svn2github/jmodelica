package org.jmodelica.util;

public enum ErrorCheckType {
    COMPILE (false, false), 
    CHECK   (true,  true);
    
    public final boolean allowOuterWithoutInner;
    public final boolean checkInactiveComponents;
    
    private ErrorCheckType(boolean allowOuterWithoutInner, boolean checkInactiveComponents) {
        this.allowOuterWithoutInner = allowOuterWithoutInner;
        this.checkInactiveComponents = checkInactiveComponents;
    }

}
