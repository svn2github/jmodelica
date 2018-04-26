package annotationMock;

import java.util.ArrayList;
import java.util.Iterator;

import org.jmodelica.common.URIResolver.URIException;
import org.jmodelica.modelica.compiler.SrcExp;
import org.jmodelica.util.annotations.AnnotationEditException;
import org.jmodelica.util.annotations.AnnotationProvider;
import org.jmodelica.util.annotations.AnnotationProvider.SubNodePair;
import org.jmodelica.util.annotations.FailedToSetAnnotationValueException;

public class MockAnnotProvider implements AnnotationProvider<MockAnnotProvider,SrcExp>,Iterable<SubNodePair<MockAnnotProvider>> {

    public String name="noname:node";
    public SrcExp value=null;
    public ArrayList<MockAnnotProvider> subNodes=new ArrayList<>();
    public ArrayList<SubNodePair<MockAnnotProvider>> subNodesB=new ArrayList<>();
    public MockAnnotProvider() {
        
    }
    
    public MockAnnotProvider(String name) {
        this.name=name;
    }

    
    @Override
    public Iterable<SubNodePair<MockAnnotProvider>> annotationSubNodes() {
        return subNodesB;
    }

    public String toString() {
        return "MockSrcAnnot:"+name;
    }
    
    @Override
    public SrcExp annotationValue() {
        return value;
    }

    @Override
    public void setAnnotationValue(SrcExp newValue) throws FailedToSetAnnotationValueException {
        value=newValue;
    }

    @Override
    public MockAnnotProvider addAnnotationSubNode(String name) throws AnnotationEditException {
       MockAnnotProvider newNode = new MockAnnotProvider(name);
       subNodesB.add(new SubNodePair<MockAnnotProvider>(name,newNode));
       subNodes.add(newNode);
       return newNode;
    }

    @Override
    public boolean isEach() {
        return false;
    }

    @Override
    public boolean isFinal() {
        return false;
    }

    @Override
    public String resolveURI(String str) throws URIException {
        return null;
    }

    @Override
    public Iterator<SubNodePair<MockAnnotProvider>> iterator() {
        return this.iterator();
    }


}
