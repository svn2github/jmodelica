package annotationMock;

import java.util.ArrayList;
import java.util.Iterator;

import org.jmodelica.common.URIResolver.URIException;
import org.jmodelica.util.annotations.AnnotationEditException;
import org.jmodelica.util.annotations.AnnotationProvider;
import org.jmodelica.util.annotations.AnnotationProvider.SubNodePair;
import org.jmodelica.util.annotations.FailedToSetAnnotationValueException;
import org.jmodelica.util.values.Evaluable;

public class DummyAnnotProvider implements AnnotationProvider<DummyAnnotProvider,Evaluable>,Iterable<SubNodePair<DummyAnnotProvider>> {

    public String name = "noname:node";
    public Evaluable value = null;
    public ArrayList<DummyAnnotProvider> subNodes = new ArrayList<>();
    public ArrayList<SubNodePair<DummyAnnotProvider>> subNodesB = new ArrayList<>();
    public DummyAnnotProvider() {
        
    }
    
    public DummyAnnotProvider(String name) {
        this.name=name;
    }

    public DummyAnnotProvider(String name, String value) {
        this.value=new DummyEvaluator(value);
        this.name=name;
    }
    
    @Override
    public Iterable<SubNodePair<DummyAnnotProvider>> annotationSubNodes() {
        return subNodesB;
    }

    public String toString() {
        return "MockSrcAnnot:" + name;
    }
    
    @Override
    public Evaluable annotationValue() {
        return value;
    }

    @Override
    public void setAnnotationValue(Evaluable newValue) throws FailedToSetAnnotationValueException {
        value = newValue;
    }

    @Override
    public DummyAnnotProvider addAnnotationSubNode(String name) throws AnnotationEditException {
       DummyAnnotProvider newNode = new DummyAnnotProvider(name);
       subNodesB.add(new SubNodePair<DummyAnnotProvider>(name, newNode));
       subNodes.add(newNode);
       return newNode;
    }
    
    public DummyAnnotProvider addAnnotationSubNode(DummyAnnotProvider prov) {
        subNodesB.add(new SubNodePair<DummyAnnotProvider>(prov.name, prov));
        subNodes.add(prov);
        return prov;
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
    public Iterator<SubNodePair<DummyAnnotProvider>> iterator() {
        return this.iterator();
    }


}
