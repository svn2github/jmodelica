package testcases;

import junit.framework.TestCase;

import org.jmodelica.ide.namecomplete.ASTNodeComparator;
import org.jmodelica.modelica.compiler.ASTNode;


@SuppressWarnings("unchecked")
public class TestASTNodeComparator extends TestCase {


public static ASTNode makeNode(int ls, int cs, int le, int ce) {
    ASTNode n = new ASTNode();
    n.setStart(ASTNode.makePosition(ls, cs)); 
    n.setEnd  (ASTNode.makePosition(le, ce));
    
    return n;
}

public void testContainsPoint() {
    
    assertTrue (ASTNodeComparator.containsPoint(
            makeNode(0,0,100,0),
            10, 10));
    
    assertTrue (ASTNodeComparator.containsPoint(
            makeNode(4,2,4,5),
            4,3));
    
    assertTrue (ASTNodeComparator.containsPoint(
            makeNode(0,0,100,0),
            99, 1000));
    
    assertTrue (ASTNodeComparator.containsPoint(
            makeNode(0,0,100,0),
            0, 0));
    
    assertTrue (ASTNodeComparator.containsPoint(
            makeNode(0,0,100,0),
            100, 0));
    
    assertFalse (ASTNodeComparator.containsPoint(
            makeNode(0,0,100,10), 
            101, 1));
    
}

public void testContainsNode() {
    
    assertTrue (ASTNodeComparator.containsNode(
            makeNode(0, 0, 100, 0),
            makeNode(0, 0, 99, 1000)));

    assertTrue (ASTNodeComparator.containsNode(
            makeNode(0, 0, 100, 0),
            makeNode(0, 0, 100, 0)));
    
    assertFalse (ASTNodeComparator.containsNode(
            makeNode(0, 0, 100, 100),
            makeNode(0, 0, 101, 0)));   
    
}

public void testMin() {

    ASTNode n1 = makeNode(0,0, 100, 0);
    
    assertTrue(
            ASTNodeComparator.min(null, null)
            == null);
    
    assertTrue(
            ASTNodeComparator.min(null, n1)
            == n1);

    assertTrue(
            ASTNodeComparator.min(n1, null)
            == n1);
    
    assertFalse(
            ASTNodeComparator.min(n1, makeNode(0, 0, 100, 0)) 
            == n1);
    
    assertFalse (
            ASTNodeComparator.min(n1, makeNode(0, 0, 99, 1000)) 
            == n1);
    
    assertTrue(
            ASTNodeComparator.min(n1, makeNode(0,0,100,1))
            == n1);
}
}
