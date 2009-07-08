package org.jmodelica.ide.indent;

import org.jmodelica.ide.indent.Indent;

/**
 * Anchor point in text, providing indentation hints.
 * 
 * @author philip
 */
public class Anchor {

public static final Indent SAME = new Indent() {
    public int modify(int indent, int indentWidth) { return indent; }
};

public final static Anchor BOTTOM = new Anchor(0, 0, SAME, "#");

public int reference;
public int offset;
public Indent indent;
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
public Anchor(int offset, int reference, Indent indent, String id) {
    this.reference = reference;
    this.offset = offset;
    this.indent = indent;
    this.id = id;
}

public Anchor(int offset, int reference) {
    this(offset, reference, SAME, null);
}

public String toString() {
    return "(" + offset + ", " + indent + ")";
}

}
