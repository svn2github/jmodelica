package org.jmodelica.util.problemHandling;

public abstract class SimpleProblemProducer extends ProblemProducer<ReporterNode> {

    private final String message;
    private final ProblemSeverity severity;

    protected SimpleProblemProducer(String identifier, ProblemKind kind, ProblemSeverity severity, String message) {
        super(identifier, kind);
        this.message = message;
        this.severity = severity;
    }

    public void invoke(ReporterNode src, Object ... args) {
        invoke(src, severity, message, args);
    }
}
