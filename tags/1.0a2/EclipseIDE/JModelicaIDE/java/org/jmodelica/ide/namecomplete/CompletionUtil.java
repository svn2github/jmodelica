package org.jmodelica.ide.namecomplete;

import org.jmodelica.modelica.compiler.Access;
import org.jmodelica.modelica.compiler.ComponentAccess;
import org.jmodelica.modelica.compiler.Dot;

public class CompletionUtil {

/**
 * 
 * Create a right-recursive dot access from a list of identifiers,
 * or a simple access if parts.length == 1.
 *  
 * @param parts parts of the qualified name
 * @return access created from parts 
 */
public static Access createDotAccess(String[] parts) {
    
    if (parts.length == 0)
        throw new IllegalArgumentException(
                "Cannot create access from zero parts");
    
    return createDotAccess(parts, 0); 
}

protected static Access createDotAccess(String[] parts, int i) {

    Access res = new ComponentAccess();
    res.setID(parts[i]);

    return i == parts.length - 1 
        ? res  
        : new Dot("", res, createDotAccess( parts, i + 1));
    
}

}
