package org.jmodelica.common.ast.prefixes;

public enum VisibilityType {
    /*
     * ordinal() is used for alias elimination so the order
     * here is important.
     */
    HIDDEN,
    TEMPORARY,
    EXPANDABLE,
    PROTECTED,
    PUBLIC,
    RUNTIME_OPTION,
    INTERFACE;
    
    public boolean isInterface() {
        return this == INTERFACE;
    }
    
    public boolean isPublic() {
        return this == PUBLIC;
    }

    public boolean isProtected() {
        return this == PROTECTED;
    }
    
    public boolean isTemporary() {
        return this == TEMPORARY;
    }

    public boolean isFromExpandableConnector() {
        return this == EXPANDABLE;
    }

    public boolean isRuntimeOptionVisibility() {
        return this == RUNTIME_OPTION;
    }
    
    public boolean isHidden() {
        return this == HIDDEN;
    }

}
