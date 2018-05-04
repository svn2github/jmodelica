package test.Annotation;

import org.jmodelica.util.annotations.*;
import org.jmodelica.util.values.Evaluable;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

import annotationMock.DummyAnnotationNode;
import annotationMock.Builder;
import annotationMock.DummyAnnotProvider;

public class GenericAnnotationNodeTest extends testUtil {
    
    public GenericAnnotationNode<DummyAnnotationNode, DummyAnnotProvider, Evaluable> createGAN(String name) {
        return createGAN(name, new DummyAnnotProvider(name), null);
    }
    
    public GenericAnnotationNode<DummyAnnotationNode, DummyAnnotProvider, Evaluable> createGAN(String name,String value) {
        return createGAN(name, new DummyAnnotProvider(name, value), null);
    }
    
    public GenericAnnotationNode<DummyAnnotationNode, DummyAnnotProvider, Evaluable> 
        createGAN(String name, DummyAnnotProvider p, GenericAnnotationNode parent) {
            return Builder.createGAN(name, p, parent);
    }
    
    public GenericAnnotationNode builder(GenericAnnotationNode node, String definition){
        return Builder.buildGAN(node, definition);
    }
    
    public void disconnectFromNode(GenericAnnotationNode node) {
        ((DummyAnnotationNode) node).disconnectFromNode();
    }

    private GenericAnnotationNode buildGAN(GenericAnnotationNode node,
            GenericAnnotationNode... subNodes) {
        for (GenericAnnotationNode subNode: subNodes) {
            (((DummyAnnotProvider)node.node())).addAnnotationSubNode(((DummyAnnotProvider)subNode.node())); 
        }
        return node;
    }

    /*
     * Test GenericAnnotationNode 
     */
    @Test 
    public void ParseBuilder1() {
        GenericAnnotationNode n = createGAN("top");
        builder(n,"a(n=3)");
        assertEquals("top(a(n=3))", n.toString());
    }
    
    @Test
    public void TestExists1() {
        GenericAnnotationNode n = createGAN("top");
        builder(n,"a(n=3)");
        n.subNodes();
        assertTrue(n.forPath("a").exists());
    }
    
    @Test
    public void TestExists2() {
        GenericAnnotationNode n = createGAN("top");
        builder(n,"a(n=3)");
        n.subNodes();
        assertFalse(n.forPath("n").exists());
    }
    
    @Test
    public void AlternateConstruction() {
        GenericAnnotationNode<DummyAnnotationNode, DummyAnnotProvider, Evaluable>  n = createGAN("top");
        buildGAN(n,buildGAN(createGAN("a"), 
            buildGAN(createGAN("n","3"), 
                buildGAN(
                    buildGAN(createGAN("u"),createGAN("v","4"))),createGAN("k","3"))
                ,createGAN("v","4"),createGAN("q","5")));
        assertEquals("top(a(n(u(v=4), k=3)=3, v=4, q=5))", n.toString());
    }
    


    @Test
    public void GenericAnnotationNodeName() {
        GenericAnnotationNode n = createGAN("top");
        builder(n,"a(n=3,v=4,q=5)");
        builder(n.forPath("a","n"),"u(v=4),k=3");
        assertTrue(n.forPath("a","n","u").exists());
        assertEquals("top(a(n(u(v=4), k=3)=3, v=4, q=5))", n.toString());
    }
    
    @Test
    public void existingFilteredIterator() {
        GenericAnnotationNode n = createGAN("top");
        builder(n,"a(n=3,v=4,q=5)");
        builder(n.forPath("a"),"u(v=4),k=3");
        disconnectFromNode(n);
        assertEmpty(n.forPath("n").subNodes().iterator());
        assertEquals("top", n.toString());
    }
    
    @Test
    public void existingFilteredIterator2() {
        GenericAnnotationNode n = createGAN("top");
        builder(n,"a(n=3,v=4,q=5)");
        builder(n.forPath("a"),"u(v=4),k=3");
        disconnectFromNode(n.forPath("n"));
        assertEmpty(n.forPath("n").subNodes().iterator());
        assertEquals("top(a(n=3, v=4, q=5, u(v=4), k=3))", n.toString());
    }
    
    @Test
    public void GenericAnnotationNode() {
        GenericAnnotationNode n = createGAN("top");
        n.forPath("a");
        n.forPath("else");
        assertEmpty(n.subNodes().iterator());
    }

}
