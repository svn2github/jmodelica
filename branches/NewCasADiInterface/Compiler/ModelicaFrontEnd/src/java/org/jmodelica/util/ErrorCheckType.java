package org.jmodelica.util;

public enum ErrorCheckType {
    COMPILE, 
    CHECK;
    
    public boolean allowOuterWithoutInner() {
        return this == CHECK;
    }
    
    public boolean allowConstantNoValue() {
        return this == CHECK;
    }
    
    public boolean allowIncompleteSizes() {
        return this == CHECK;
    }
    
    public boolean allowIncompleteReplaceableFunc() {
        return this == CHECK;
    }
    
    public boolean checkInactiveComponents() {
        return this == CHECK;
    }

}
