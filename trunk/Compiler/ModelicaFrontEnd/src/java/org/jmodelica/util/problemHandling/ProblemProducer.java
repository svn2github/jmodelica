package org.jmodelica.util.problemHandling;

public abstract class ProblemProducer<T extends ReporterNode> {

    private final String identifier;
    private final ProblemKind kind;

    protected ProblemProducer(String identifier, ProblemKind kind) {
        this.identifier = identifier;
        this.kind = kind;
    }

    protected void invoke(T src, ProblemSeverity severity, String message, Object ... args) {
        src.reportProblem(new Problem(identifier, src, severity, kind, String.format(message, args)));
    }
}
