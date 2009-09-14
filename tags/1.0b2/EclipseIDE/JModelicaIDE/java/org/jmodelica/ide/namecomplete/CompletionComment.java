package org.jmodelica.ide.namecomplete;

import org.jmodelica.ide.helpers.Maybe;


/**
 * Represents optional comment on a Modelica class, as shown in Content Assist.
 * 
 * @author philip
 * 
 */
public class CompletionComment extends Maybe<String> {

// type erasure sucks
public final static CompletionComment NULL = new CompletionComment(null);

public CompletionComment(String str) { super(str); }

public String toString() {
    return isNothing() ? "" : "  -  " + value;
}

}
