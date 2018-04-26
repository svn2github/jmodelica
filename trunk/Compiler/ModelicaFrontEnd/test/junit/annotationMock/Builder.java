package annotationMock;

import java.io.IOException;

import org.jmodelica.modelica.compiler.ParserException;
import org.jmodelica.modelica.compiler.ParserHandler;
import org.jmodelica.modelica.compiler.SrcAnnotationProvider;
import org.jmodelica.modelica.compiler.SrcArgument;
import org.jmodelica.util.annotations.GenericAnnotationNode;
import org.jmodelica.util.annotations.AnnotationProvider.SubNodePair;

import com.sun.corba.se.impl.orbutil.graph.Node;

import beaver.Parser.Exception;

public class Builder {
    public static GenericAnnotationNode createGAN(String name, MockAnnotProvider p, GenericAnnotationNode parent) {
        return new MockAnnotationNode("hello",p, (MockAnnotationNode) parent);
    }
    
    public static GenericAnnotationNode buildGAN(GenericAnnotationNode n, String defs){
        try {
            MockAnnotationNode root = (MockAnnotationNode) n;
            SrcArgument data = new ParserHandler().parseModifier(defs, "notAFile");
            if (data.annotationValue()!=null) {
                root.setValue(data.annotationValue());
            }
            for(SubNodePair<SrcAnnotationProvider> x : data.annotationSubNodes()) {
                root.node().addAnnotationSubNode(x.name);
                recursionBuild(root.forPath(x.name),x.node);
            }

        } catch (ParserException | Exception | IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return n;
    }

    private static void recursionBuild(MockAnnotationNode root,
            SrcAnnotationProvider node) {
        if (node.annotationValue()!=null) {
            root.setValue(node.annotationValue());
        }
        for(SubNodePair<SrcAnnotationProvider> x : node.annotationSubNodes()) {
            root.node().addAnnotationSubNode(x.name);
            recursionBuild(root.forPath(x.name),x.node);
            
        }
    }
}
