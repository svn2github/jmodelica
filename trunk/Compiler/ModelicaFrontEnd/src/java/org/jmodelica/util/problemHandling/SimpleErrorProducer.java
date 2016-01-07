package org.jmodelica.util.problemHandling;

public class SimpleErrorProducer extends SimpleProblemProducer {

    public SimpleErrorProducer(String identifier, ProblemKind kind, String message) {
        super(identifier, kind, ProblemSeverity.ERROR, message);
    }

}
