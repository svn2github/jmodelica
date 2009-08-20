package org.jmodelica.ide.namecomplete;

import org.jmodelica.ide.helpers.Maybe;


/**
 * Represents optional comment on a Modelica class, as shown in Content Assist.
 * 
 * @author philip
 * 
 */
public class CompletionComment extends Maybe<String> {

// you of course cannot define a NULL object in Maybe<E>, cause a static value
// is shared between all instances of a class. because of type erasure this
// means _all_ instances of Maybe<Anything>. yay for java!
public final static CompletionComment NULL = new CompletionComment();

// boiler plate super constructor calls are also so much fun
public CompletionComment() { super(); }
public CompletionComment(String str) { super(str); }

public String toString() {
    return isNothing() ? "" : "  -  " + value;
}

}
