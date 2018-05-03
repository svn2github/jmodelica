package annotationMock;

public class DummySrcArgument extends DummyAnnotProvider {
    
    public  DummySrcArgument fullCopy() {
        // TODO Auto-generated method stub
        return this;
    }

    public  DummySrcArgument treeCopyNoTransform() {
        // TODO Auto-generated method stub
        return this;
    }

    public  DummySrcArgument treeCopy() {
        // TODO Auto-generated method stub
        return this;
    }

    public void addAnnotationSubNode(DummySrcArgument arg) {
            subNodesB.add(new SubNodePair<DummyAnnotProvider>(arg.name,arg));
            subNodes.add(arg);
    }

}
