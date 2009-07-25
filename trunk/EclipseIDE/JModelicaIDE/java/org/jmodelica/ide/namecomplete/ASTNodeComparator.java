package org.jmodelica.ide.namecomplete;

import org.jmodelica.modelica.compiler.ASTNode;


/**
 * <p>
 * Define a partial order on {@link ASTNode}s s.t. <code>node1</code> &le;
 * <code>node2</code> iff. the textual representation of node1 if contained in
 * <code>node2</code> (or <code>node2 == null</code>).
 * </p>
 * 
 * <p>
 * E.g. in:
 * </p>
 * 
 * <code>
 * class m<br>
 * &nbsp;&nbsp;Real r;<br>
 * end m;<br>
 * </code>
 * 
 * <p>
 * the {@link ASTNode} corresponding to <code>Real r</code> &le; the
 * {@link ASTNode} corresponding to <code>class m ... end m</code>.
 * </p>
 * 
 * <p>
 * This class compares {@link ASTNode}s according to this relation
 * </p>
 * 
 * @author philip
 * 
 */
public class ASTNodeComparator {

/**
 * Returns <code>n2</code> if <code>n2</code> &le; <code>n1</code>, else returns
 * <code>n1</code>;
 */
public static ASTNode min(ASTNode n1, ASTNode n2) {
    
    if (n1 == null)
        return n2;
    if (n2 == null)
        return n1;
    
    return containsNode(n1, n2) ? n2 : n1;
}

/**
 * Returns true iff.&nbsp; <code>node</code>'s textual representation contains
 * <code>(line, col)</code>.
 */
public static boolean containsPoint(ASTNode node, int line, int col) {
    
    boolean beginsBefore = 
        node.getBeginLine() == line && node.getBeginColumn() <= col ||
        node.getBeginLine() < line;
    
    boolean endsAfter = 
        node.getEndLine() == line && node.getEndColumn() >= col ||
        node.getEndLine() > line;
    
    return beginsBefore && endsAfter;
}

/**
 * Returns true iff.&nbsp; <code>n1</code>'s textual representation contains contains
 * <code>n2</code>'s textual representation.
 */
public static boolean containsNode(ASTNode n1, ASTNode n2) {
    
    return containsPoint(n1, n2.getBeginLine(), n2.getBeginColumn()) &&
           containsPoint(n1, n2.getEndLine(), n2.getEndColumn());       
}

    
}
