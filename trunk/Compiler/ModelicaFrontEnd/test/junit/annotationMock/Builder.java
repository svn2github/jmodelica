package annotationMock;

import java.util.LinkedList;
import java.util.Scanner;
import java.util.regex.Pattern;

import org.jmodelica.util.annotations.GenericAnnotationNode;
import org.jmodelica.util.annotations.AnnotationProvider.SubNodePair;
import org.jmodelica.util.values.Evaluable;
import org.jmodelica.util.annotations.FailedToSetAnnotationValueException;

public class Builder {

    public static GenericAnnotationNode<DummyAnnotationNode, DummyAnnotProvider, Evaluable> 
        createGAN(String name, DummyAnnotProvider p, GenericAnnotationNode parent) {
            return new DummyAnnotationNode(name, p, (DummyAnnotationNode) parent);
    }
    
    
    public static GenericAnnotationNode buildGAN(GenericAnnotationNode n, String definition){
            DummyAnnotationNode root = (DummyAnnotationNode) n;
            DummySrcArgument data = parseModifier(definition);
            if (data.annotationValue() != null) {
                root.setValue(data.annotationValue());
            }
            for(SubNodePair<DummyAnnotProvider> subNode : data.annotationSubNodes()) {
                root.node().addAnnotationSubNode(subNode.name);
                recursionBuild(root.forPath(subNode.name),subNode.node);
            }
        return n;
    }

    private static DummySrcArgument parseModifier(String definition) {
        Scanner scanner = new Scanner(definition);
        Pattern word = Pattern.compile("\\w+([=]?\\w+)?");
        Pattern level = Pattern.compile("[(]");
        Pattern lower = Pattern.compile("[)]");
        Pattern comma = Pattern.compile("[,]"); 
        scanner.useDelimiter("");
        DummySrcArgument arg = new DummySrcArgument();
        LinkedList<DummySrcArgument> levels = new LinkedList<DummySrcArgument>();
        levels.add(arg);
        while (scanner.hasNext()) {
            if (scanner.hasNext(word)) {
                String item = scanner.findWithinHorizon(word, 0);
                if (item.contains("=")) {
                    int equals= item.indexOf("=");
                    arg = new DummySrcArgument();
                    arg.name = item.substring(0, equals);
                    levels.getFirst().addAnnotationSubNode(arg); 
                    try {
                        arg.setAnnotationValue(new DummyEvaluator(item.substring(equals + 1)));
                    } catch (FailedToSetAnnotationValueException e) {
                        e.printStackTrace();
                    }
                }else {
                    arg = new DummySrcArgument();
                    arg.name = item;
                    levels.getFirst().addAnnotationSubNode(arg); 
                }
            }else if (scanner.hasNext(comma)) {
                scanner.next(comma);
            } else if (scanner.hasNext(level)) {
                scanner.next(level);
                if (arg == null) {
                    arg = new DummySrcArgument();
                    levels.getFirst().addAnnotationSubNode(arg); 
                }
                levels.push(arg);
                arg = null;
            } else if (scanner.hasNext(lower)) {
                scanner.next(lower);
                levels.pop();
            }
        }
        scanner.close();
        return levels.getFirst();
    }


    private static void recursionBuild(DummyAnnotationNode root,
            DummyAnnotProvider node) {
        if (node.annotationValue() != null) {
            root.setValue(node.annotationValue());
        }
        for(SubNodePair<DummyAnnotProvider> subNode : node.annotationSubNodes()) {
            root.node().addAnnotationSubNode(subNode.name);
            recursionBuild(root.forPath(subNode.name), subNode.node);
            
        }
    }
}
