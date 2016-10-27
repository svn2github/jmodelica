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
    public String identifier() {
        return identifier;
    }
    
    protected final int beginLine;
    protected final int beginColumn;
    public int beginLine() { return beginLine; }
    public int beginColumn() { return beginColumn; }
  
    protected String fileName;
    public String fileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }

    public boolean hasLocation() { return fileName != null; }

    protected final String message;
    public String message() { return message; }

    protected final ProblemSeverity severity;
    public ProblemSeverity severity() { return severity; }

    protected final ProblemKind kind;
    public ProblemKind kind() { return kind; }

    protected Set<String> components = new TreeSet<String>(); // TreeSet is used so that we get a sorted set

    public void addComponent(String component) {
        if (component != null)
            components.add(component);
    }

    public Collection<String> components() { return components; }

    @Deprecated
    public Problem(String fileName, String message) {
        this(fileName, message, ProblemSeverity.ERROR);
    }

    @Deprecated
    public Problem(String fileName, String message, ProblemSeverity severity) {
        this(fileName, message, severity, ProblemKind.OTHER);
    }

    @Deprecated
    public Problem(String fileName, String message, ProblemSeverity severity, ProblemKind kind) {
        this(null, fileName, message, severity, kind, 0, 0);
    }

    @Deprecated
    public Problem(String fileName, String message, ProblemSeverity severity, ProblemKind kind, int beginLine, int beginColumn) {
        this(null, fileName, message, severity, kind, beginLine, beginColumn);
    }
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

    public boolean isTestError(boolean checkAll) {
        return checkAll || (severity == ProblemSeverity.ERROR && kind != ProblemKind.COMPLIANCE);
    }

    public boolean equals(Object o) {
        return (o instanceof Problem) && (compareTo((Problem) o) == 0);
    }

    public static String capitalize(Object o) {
        String name = o.toString();
        return Character.toUpperCase(name.charAt(0)) + name.substring(1).toLowerCase();
    }

    public void merge(Problem p) {
        components.addAll(p.components);
    }

    @Override
    public String toString() {
        return toString(false);
    }

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

