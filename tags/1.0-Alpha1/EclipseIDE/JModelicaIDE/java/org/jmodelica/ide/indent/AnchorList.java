package org.jmodelica.ide.indent;

/**
 * By implementing this interface and using {@link IndentingAutoEditStrategy}
 * you get an indenting editing strategy using the hints provided.
 * 
 * {@link IndentedSection#indent(AnchorList)} similarly indents a given string
 * of source code, using provided hints.
 * 
 * @author philip
 * 
 */
public interface AnchorList {

/**
 * Give an anchor 
 * @param offset
 * @return
 */
public Anchor anchorAt(int offset);

public Anchor sinkAt(int offset);

}
