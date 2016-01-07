package org.jmodelica.util.problemHandling;

public class SimpleWarningProducer extends SimpleProblemProducer {

    public SimpleWarningProducer(String identifier, ProblemKind kind, String message) {
        super(identifier, kind, ProblemSeverity.WARNING, message);
    }

}
