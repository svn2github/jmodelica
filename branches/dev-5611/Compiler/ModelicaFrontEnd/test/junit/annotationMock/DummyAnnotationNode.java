package annotationMock;

import org.jmodelica.util.annotations.GenericAnnotationNode;
import org.jmodelica.util.values.Evaluable;

public class DummyAnnotationNode extends GenericAnnotationNode<DummyAnnotationNode, DummyAnnotProvider, Evaluable> {

    private static DummyAnnotationNode ambiguousNode = new DummyAnnotationNode("Ambiguous", null, null);
    public DummyAnnotationNode(String name, DummyAnnotProvider node, DummyAnnotationNode parent) {
        super(name, node, parent);
    }

    
    public void disconnectFromNode() {
        super.disconnectFromNode();
    }
    
    @Override
    protected DummyAnnotationNode self() {
        return this;
    }

    
    @Override
    protected DummyAnnotationNode createNode(String name, DummyAnnotProvider node) {
        return new DummyAnnotationNode(name, node, this);
    }

    
    @Override
    protected DummyAnnotProvider valueAsProvider() {
        return node();
    }

    @Override
    protected DummyAnnotationNode ambiguousNode() {
        return ambiguousNode;
    }
    
}
