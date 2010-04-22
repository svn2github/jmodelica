package org.jmodelica.ide.indent;

/**
 * By implementing this interface and using {@link IndentingAutoEditStrategy}
 * you get an indenting editing strategy using the hints provided.
 * 
 * 
 * {@link IndentedSection#indent(AnchorList)} similarly indents a given string
 * of source code, using provided hints.
 * 
 * The {@link AnchorList#anchorAt(int)} method should return the indentation
 * valid at given offset. It is also possible to add "sinks" that if they exists
 * on the line of the offset, override the current normal anchor, and
 * additionally causes {@link IndentingAutoEditStrategy} to re-indent the
 * current line when the user inputs a newline. This can be used to implement
 * behaviour like "}"'s sinking back to the last indent.
 * 
 * 
 * @author philip
 * 
 */
public interface AnchorList<E> {

/**
 * Return anchor valid at offset. Should not return null.
 * 
 * @param offset
 * @return anchor at offset
 */
public Anchor<E> anchorAt(int offset);

/**
 * Return sink valid at offset. May return null.
 * 
 * @param offset offset
 * @return anchor at offset
 */
public Anchor<E> sinkAt(int offset);

}
