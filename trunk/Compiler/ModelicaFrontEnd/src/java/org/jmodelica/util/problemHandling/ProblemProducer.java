package org.jmodelica.util.problemHandling;

/**
 * Base class for all problem producers. An instance of a problem producer
 * (or sub classes) represents a unique type of error or warning that the 
 * compiler can issue during compilation. All problems given by the compiler
 * during compilation should ideally be produced and returned by a instance of
 * problem producer. This ensures that we can provide the user with the means
 * for filtering and categorizing the problems given.
 *
 * All instances of this and sub-classes should be declared as static final on
 * ASTNode!
 * 
 * @param <T> Generic type that allows for sub classes which need access to 
 *      specific classes that implement ReporterNode, hint hint, a sub class
 *      of ASTNode!
 */
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
