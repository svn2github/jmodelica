package org.jmodelica.util.problemHandling;

/**
 * Convenient class which takes a string message on construction, an
 * optional list of format arguments when invoked and produces a warning.
 */
public class SimpleWarningProducer extends SimpleProblemProducer {

    public SimpleWarningProducer(String identifier, ProblemKind kind, String message) {
        super(identifier, kind, ProblemSeverity.WARNING, message);
    }

}
