package org.jmodelica.test.Annotation;

import org.jmodelica.test.common.AssertMethods;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static annotationMock.Builder.newProvider;
import org.junit.Test;

import annotationMock.DummyAnnotationNode;
import annotationMock.DummyAnnotProvider;

public class GenericAnnotationNodeTest extends AssertMethods {

    /**
     * Create a standard construction top(a(ab=4,ab=5)=1, b(ba=1,bb=2)=2, c=3)
     * 
     */
    public DummyAnnotationNode CreateDefault() {
        DummyAnnotProvider n = newProvider("top");
        DummyAnnotProvider a = newProvider("a", 1);
        DummyAnnotProvider b = newProvider("b", 2);
        a.addNodes(newProvider("ab", 4), newProvider("ab", 5));
        b.addNodes(newProvider("ba", 1), newProvider("bb", 2));
        n.addNodes(a, b, newProvider("c", 3));
        return n.createAnnotationNode();
    }

    /*
     * Test GenericAnnotationNode
     */
    @Test
    public void testValueAsAnnotationForAmbiguous() {
        DummyAnnotationNode n = CreateDefault();
        assertTrue(n.forPath("a", "ab").valueAsAnnotation().isAmbiguous());
    }

    @Test
    public void testToStringExisting() {
        DummyAnnotProvider n = newProvider("top");
        n.addNodes(newProvider("a").addNodes(newProvider("n", 3)));
        DummyAnnotationNode testNode = n.createAnnotationNode();

        assertEquals("top(a(n=3))", testNode.toString());
    }

    @Test
    public void testExistsForExistingNode() {
        DummyAnnotProvider n = newProvider("top");
        n.addNodes(newProvider("a").addNodes(newProvider("n", 3)));
        DummyAnnotationNode testNode = n.createAnnotationNode();

        assertTrue(testNode.forPath("a").exists());
    }

    @Test
    public void testExistingForNonexistingNode() {
        DummyAnnotProvider n = newProvider("top");
        n.addNodes(newProvider("a").addNodes(newProvider("n", 3)));

        DummyAnnotationNode testNode = n.createAnnotationNode();
        assertFalse(testNode.forPath("n").exists());
    }

    @Test
    public void testExistAfterReplaced() {
        DummyAnnotationNode top = newProvider("top").addNodes(newProvider("test")).createAnnotationNode();
        DummyAnnotationNode replaced = top.forPath("test");
        top.disconnectFromNode();
        top.testSrcRemoveAll();
        top.setNode("top", newProvider("p"));
        assertFalse(replaced.exists());
    }

    @Test
    public void testConstructionOfComplexNode () {
        DummyAnnotProvider n = newProvider("top");
        n.addNodes(newProvider("a").addNodes(
                newProvider("n", "3").addNodes(newProvider("u").addNodes(newProvider("v", "4")), newProvider("k", "3")),
                newProvider("v", "4"), newProvider("q", "5")));
        DummyAnnotationNode testNode = n.createAnnotationNode();

        assertEquals("top(a(n(u(v=4), k=3)=3, v=4, q=5))", testNode.toString());
    }

    @Test
    public void updateNode() {
        DummyAnnotationNode n = CreateDefault();
        n.updateNode("newTop", n.node());
        assertEquals("newTop(a(ab=4, ab=5)=1, b(ba=1, bb=2)=2, c=3)", n.toString());
    }

    @Test
    public void existingFilteredIterator() {
        DummyAnnotationNode n = CreateDefault();
        n.testSrcRemoveAll();
        n.disconnectFromNode();
        assertEmpty(n.forPath("a").subNodes().iterator());
        assertEquals("n", n.forPath("n").toString());
    }

    @Test
    public void existingFilteredIterator2() {
        DummyAnnotationNode n = CreateDefault();
        n.forPath("a").testSrcRemoveAll();
        n.forPath("a").disconnectFromNode();
        assertEmpty(n.forPath("a").subNodes().iterator());
        assertEquals("top(a=1, b(ba=1, bb=2)=2, c=3)", n.toString());
    }

    @Test
    public void recalculatedFromSource() {
        DummyAnnotationNode n = CreateDefault();
        n.forPath("b").disconnectFromNode(); // Source untouched.
        assertEquals("top(a(ab=4, ab=5)=1, b(ba=1, bb=2)=2, c=3)", n.toString());
    }

    @Test
    public void testForPathNoneCreating() {
        DummyAnnotationNode testNode = newProvider("top").createAnnotationNode();
        testNode.forPath("a");
        testNode.forPath("else");
        assertEmpty(testNode.subNodes());
    }

    @Test
    public void disconnectNonExistentNode() {
        DummyAnnotationNode n = CreateDefault();
        String orginal = n.toString();
        n.forPath("n").disconnectFromNode();
        assertEquals(orginal, n.toString());
    }

    @Test
    public void testReplaceWithSubNodes() {
        DummyAnnotProvider n = newProvider("top");
        n.addNodes(newProvider("a").addNodes(newProvider("n", 3)));
        DummyAnnotProvider replacement = new DummyAnnotProvider("newNode");
        replacement.addAnnotationSubNode("a").addNodes(new DummyAnnotProvider("aa", 1));
        DummyAnnotationNode testNode = n.createAnnotationNode();

        DummyAnnotationNode replacementNode = testNode.forPath("a", "n");
        replacementNode.setNode("newName", replacement);

        testNode.forPath("a").node().subNodes.clear();
        testNode.forPath("a").node().addNodes(replacement);

        assertFalse(replacementNode.exists());
        assertEquals("top(a(newNode(a(aa=1))))", testNode.toString());
    }
}
