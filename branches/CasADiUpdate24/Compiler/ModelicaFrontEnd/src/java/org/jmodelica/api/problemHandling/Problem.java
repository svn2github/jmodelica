/*
    Copyright (C) 2015 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package org.jmodelica.api.problemHandling;

import java.util.Collection;
import java.util.Set;
import java.util.TreeSet;

import org.jmodelica.util.logging.Level;
import org.jmodelica.util.logging.XMLLogger;
import org.jmodelica.util.logging.units.LoggingUnit;
import org.jmodelica.util.problemHandling.ReporterNode;
import org.jmodelica.util.problemHandling.WarningFilteredProblem;

/**
 * Represents a error or warning given by the compiler during compilation of
 * a model. It contains information about where, type, severity and message
 * about the problem.
 */
public class Problem implements Comparable<Problem>, LoggingUnit {
    private static final long serialVersionUID = 2;
    
    @Override
    public int compareTo(Problem other) {
        if (kind.order != other.kind.order)
            return kind.order - other.kind.order;
        if (fileName == null || other.fileName == null) {
            if (fileName != null)
                return -1;
            if (other.fileName != null)
                return 1;
        } else {
            if (!fileName.equals(other.fileName))
                return fileName.compareTo(other.fileName);
        }
        if (beginLine != other.beginLine)
            return beginLine - other.beginLine;
        if (beginColumn != other.beginColumn)
            return beginColumn - other.beginColumn;
        if (identifier != null && other.identifier != null && !identifier.equals(other.identifier)) {
            return identifier.compareTo(other.identifier);
        }
        return message.compareTo(other.message);
    }

    protected final String identifier;
    
    /**
     * @return a string identifier specifying the problem.
     */
    public String identifier() {
        return identifier;
    }
    
    protected final int beginLine;
    protected final int beginColumn;

    /**
     * @return the line in the source file where the problem was encountered.
     */
    public int beginLine() { return beginLine; }
    
    /**
     * @return the column in the source file where the problem was encountered.
     */
    public int beginColumn() { return beginColumn; }
  
    protected String fileName;

    /**
     * @return the name of the source file of the problem.
     */
    public String fileName() { return fileName; }

    /** 
     * @param fileName the name of the file to set as the problem's source.
     */
    public void setFileName(String fileName) { this.fileName = fileName; }

    /**
     * @return {@code true} if the source file of the problem is known, {@code false} otherwise.
     */
    public boolean hasLocation() { return fileName != null; }

    protected final String message;

    /**
     * @return the problem message (presented when the error is reported).
     */
    public String message() { return message; }

    protected final ProblemSeverity severity;

    /**
     * @return the problem severity.
     */
    public ProblemSeverity severity() { return severity; }

    protected final ProblemKind kind;

    /**
     * @return the problem type.
     */
    public ProblemKind kind() { return kind; }

    protected Set<String> components = new TreeSet<String>(); // TreeSet is used so that we get a sorted set

    /**
     * @param component
     *          The component to add to the problem.
     */
    public void addComponent(String component) {
        if (component != null)
            components.add(component);
    }

    /**
     * @return a collection of the problem's components.
     */
    public Collection<String> components() { return components; }

    /**
     * Deprecated in favour of {@link Problem#createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)
     * createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)}.
     */
    @Deprecated
    public Problem(String fileName, String message) {
        this(fileName, message, ProblemSeverity.ERROR);
    }

    /**
     * Deprecated in favour of {@link Problem#createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)
     * createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)}.
     */
    @Deprecated
    public Problem(String fileName, String message, ProblemSeverity severity) {
        this(fileName, message, severity, ProblemKind.OTHER);
    }

    /**
     * Deprecated in favour of {@link Problem#createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)
     * createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)}.
     */
    @Deprecated
    public Problem(String fileName, String message, ProblemSeverity severity, ProblemKind kind) {
        this(null, fileName, message, severity, kind, 0, 0);
    }

    /**
     * Deprecated in favour of {@link Problem#createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)
     * createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)}.
     */
    @Deprecated
    public Problem(String fileName, String message, ProblemSeverity severity, ProblemKind kind, int beginLine, int beginColumn) {
        this(null, fileName, message, severity, kind, beginLine, beginColumn);
    }

    /**
     * Deprecated in favour of {@link Problem#createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)
     * createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)}.
     */
    @Deprecated
    protected Problem(String identifier, String fileName, String message, ProblemSeverity severity, ProblemKind kind, int beginLine, int beginColumn) {
        this.identifier = identifier;
        this.fileName = fileName;
        this.message = message;
        this.severity = severity;
        this.kind = kind;
        this.beginLine = beginLine;
        this.beginColumn = beginColumn;
        
        if (message == null)
            throw new NullPointerException();
    }
    
//    public Problem(String identifier, ReporterNode src, ProblemSeverity severity, ProblemKind kind, String message) {
//        this(identifier, src.fileName(), message, severity, kind, src.lineNumber(), src.columnNumber());
//        if (src.myOptions().getBooleanOption("component_names_in_errors")) {
//            addComponent(src.errorComponentName());
//        }
//    }
//    
    /**
     * Creates a {@code Problem} object.
     * 
     * @param identifier
     *      The problem's identifier.
     * @param src
     *      The node which reported the problem (the problem source).
     * @param severity
     *      The severity level of the problem (error, warning).
     * @param kind
     *      The type of the problem (syntactical, semantical, et.c.).
     * @param message
     *      The message to present when the error is reported.
     * @return
     *      a {@code Problem} instance.
     */
    public static Problem createProblem(String identifier, ReporterNode src, ProblemSeverity severity, ProblemKind kind, String message) {
        Problem p;
        if (src == null) {
            // TODO, insert something else than null in filename, that way we
            // can differentiate between errors in flattened model and generic
            // errors
            p = new Problem(identifier, null, message, severity, kind, 0, 0);
        } else {
            if (identifier != null && severity == ProblemSeverity.WARNING && src.myProblemOptionsProvider().filterThisWarning(identifier)) {
                return new WarningFilteredProblem();
            }
            p = new Problem(identifier, src.fileName(), message, severity, kind, src.lineNumber(), src.columnNumber());
            if (src.myProblemOptionsProvider().getOptionRegistry().getBooleanOption("component_names_in_errors")) {
                p.addComponent(src.errorComponentName());
            }
        }
        return p;
    }

    /**
     * @param checkAll
     *      A flag specifying whether or not to include all problems.
     * @return
     *      {@code true} if the error is for testing, {@code false} otherwise.
     */
    public boolean isTestError(boolean checkAll) {
        return checkAll || (severity == ProblemSeverity.ERROR && kind != ProblemKind.COMPLIANCE);
    }

    @Override
    public boolean equals(Object o) {
        return (o instanceof Problem) && (compareTo((Problem) o) == 0);
    }

    /**
     * @param o
     *      The object whose string representation should be capitalized.
     * @return a capitalized string representation of {@code o}.
     */
    public static String capitalize(Object o) {
        String name = o.toString();
        return Character.toUpperCase(name.charAt(0)) + name.substring(1).toLowerCase();
    }

    /**
     * Joins together two problems.
     * 
     * @param p
     *      The {@code Problem} to join with {@code this}.
     */
    public void merge(Problem p) {
        components.addAll(p.components);
    }

    @Override
    public String toString() {
        return toString(false);
    }

    /**
     * @param printIdentifier
     *          A flag specifying whether or not the identifier should be included in the string representation.
     * @return
     *          A string representation of the {@code Problem}.
     */
    public String toString(boolean printIdentifier) {
        StringBuilder sb = new StringBuilder();
        kind.writeKindAndSeverity(sb, severity);
        if (fileName == null) {
            sb.append(" in flattened model");
        } else {
            sb.append(" at line ");
            sb.append(beginLine);
            sb.append(", column ");
            sb.append(beginColumn);
            sb.append(", in file '");
            sb.append(fileName);
            sb.append("'");
        }
        if (printIdentifier && identifier != null) {
            sb.append(", " + identifier);
        }
        if (!components.isEmpty()) {
            sb.append(",\n");
            if (components.size() > 1) {
                int limit = 4;
                sb.append("In components:\n");
                int i = 0;
                if (limit + 1 == components.size())
                    limit += 1;
                for (String component : components) {
                    i++;
                    sb.append("    ");
                    sb.append(component);
                    sb.append("\n");
                    if (i == limit) break;
                }
                if (components.size() > limit) {
                    sb.append("    .. and ");
                    sb.append(components.size() - limit);
                    sb.append(" additional components\n");
                }
            } else {
                sb.append("In component ");
                sb.append(components.iterator().next());
                sb.append(":\n");
            }
        } else {
            sb.append(":\n");
        }
        sb.append("  ");
        sb.append(message());
        return sb.toString();
    }

    @Override
    public String print(Level level) {
        return toString(level.shouldLog(Level.INFO));
    }

    @Override
    public String printXML(Level level) {
        return XMLLogger.write_node(Problem.capitalize(severity()), 
                "identifier",   identifier() == null ? "" : identifier(),
                "kind",         kind().toString().toLowerCase(),
                "file",         fileName(),
                "line",         beginLine(),
                "column",       beginColumn(),
                "message",      message());
    }

    @Override
    public void prepareForSerialization() {
    }
}

