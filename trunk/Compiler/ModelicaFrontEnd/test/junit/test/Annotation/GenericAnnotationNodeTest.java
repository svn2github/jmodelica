package test.Annotation;

import org.jmodelica.util.annotations.*;
import org.jmodelica.util.annotations.AnnotationProvider.SubNodePair;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.io.IOException;

import org.jmodelica.modelica.compiler.ParserException;
import org.jmodelica.modelica.compiler.ParserHandler;
import org.jmodelica.modelica.compiler.SrcAnnotationProvider;
import org.jmodelica.modelica.compiler.SrcArgument;
import org.junit.Test;

import annotationMock.MockAnnotationNode;
import annotationMock.Builder;
import annotationMock.MockAnnotProvider;
import beaver.Parser.Exception;

public class GenericAnnotationNodeTest extends testUtil {
    
    public GenericAnnotationNode createGAN(String name) {
        return createGAN("hello",new MockAnnotProvider(),null);
    }
    
    public GenericAnnotationNode createGAN(String name, MockAnnotProvider p, GenericAnnotationNode parent) {
        return Builder.createGAN(name,p, parent);
    }
    
    public GenericAnnotationNode builder(GenericAnnotationNode n, String defs){
        return Builder.buildGAN(n,defs);
    }
    
    public void disconnectFromNode(GenericAnnotationNode g) {
        ((MockAnnotationNode) g).disconnectFromNode();
    }

    /*
     * Test GenericAnnotationNode 
     */
    @Test
    public void GenericAnnotationNodeExample() {
        GenericAnnotationNode n = createGAN("hello");
        builder(n,"a(n=3)");
        assertTrue(n.forPath("n").exists());
    }
    
    @Test
    public void GenericAnnotationNodeName() {
        GenericAnnotationNode n = createGAN("hello");
        builder(n,"a(n=3,v=4,q=5)");
        builder(n.forPath("n"),"n(u(v=4),k=3)");
        assertTrue(n.forPath("n").exists());
        assertEquals("hello(n(u(v=4), k=3)=3, v=4, q=5)", n.toString());
    }
    
    @Test
    public void existingFilteredIterator() {
        GenericAnnotationNode n = createGAN("hello");
        builder(n,"a(n=3,v=4,q=5)");
        builder(n.forPath("n"),"n(u(v=4),k=3)");
        disconnectFromNode(n);
        assertEmpty(n.forPath("n").subNodes().iterator());
        assertEquals("v=4,q=5", n.toString());
    }
    
    @Test
    public void GenericAnnotationNode() {
        GenericAnnotationNode n = createGAN("hello");
        builder(n,"a(n=3)");
        n.forPath("a");
        n.forPath("else");
        assertEmpty(n.subNodes().iterator());
    }

}
