package annotationMock;

import java.util.ArrayList;

import org.jmodelica.modelica.compiler.SrcExp;
import org.jmodelica.util.annotations.GenericAnnotationNode;

public class MockAnnotationNode extends GenericAnnotationNode<MockAnnotationNode, MockAnnotProvider, SrcExp> {

    private static MockAnnotationNode ambiguousNode = new MockAnnotationNode("Ambiguous", null, null);
    public MockAnnotationNode(String name, MockAnnotProvider node, MockAnnotationNode parent) {
        super(name, node, parent);
        // TODO Auto-generated constructor stub
    }

    public void disconnectFromNode() {
        super.disconnectFromNode();
    }
    
    @Override
    protected MockAnnotationNode self() {
        // TODO Auto-generated method stub
        return this;
    }

    @Override
    protected MockAnnotationNode createNode(String name, MockAnnotProvider node) {
        return new MockAnnotationNode(name, node, this);
    }

    
    @Override
    protected MockAnnotProvider valueAsProvider() {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    protected MockAnnotationNode ambiguousNode() {
        // TODO Auto-generated method stub
        return ambiguousNode;
    }
}
