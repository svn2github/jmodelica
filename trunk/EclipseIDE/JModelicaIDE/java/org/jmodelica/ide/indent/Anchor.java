package org.jmodelica.ide.indent;


/**
 * Anchor point in text, providing indentation hints. The anchor represents an
 * indentation hint saying at offset <code>offset</code>, the indent should be
 * the same as at <code>reference</code>, modified by Indent.
 * 
 * Type parameter E represents the indentation modifier of the anchor, and a
 * list needs to be transformed to AnchorList&lt;Integer&gt; before use of any
 * of the classes in this package.
 * 
 * The type parameter exists to be able to let the code creating the list be
 * agnostic of things like tab width, and other environment variables, which 
 * can instead be bound later.
 * 
 * @author philip
 */
public class Anchor<E> {

public int reference;
public int offset;
public E indent;
public String id;

/**
 * Create an Anchor at <code>offset</code>. Indent in region after anchor should
 * be the same as at offset <code>reference</code>, adjusted with
 * <code>indent</code>.
 * 
 * @param offset offset of anchor
 * @param reference reference offset for indentation
 * @param indent adjust from reference
 * @param id name of anchor to identify where it came from
 * @param modifiesCurrentLine if anchor changes indentation of current line
 *            rather than the following text
 */
public Anchor(int offset, int reference, E indent, String id) {
    this.reference = reference;
    this.offset = offset;
    this.indent = indent;
    this.id = id;
}

public String toString() {
    return "(" + offset + ", " + indent + ", " + id + ")";
}

}
