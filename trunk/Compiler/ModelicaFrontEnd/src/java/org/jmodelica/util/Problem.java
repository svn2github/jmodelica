package org.jmodelica.util;

import java.io.Serializable;
import java.util.Collection;
import java.util.Set;
import java.util.TreeSet;

public class Problem implements Comparable<Problem>, Serializable {
    private static final long serialVersionUID = 1;
    
    public int compareTo(Problem other) {
        if (fileName == null) {
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
        return message.compareTo(other.message);
    }

    public enum Severity { ERROR, WARNING }

    public enum Kind { 
        OTHER, LEXICAL("Syntax"), SYNTACTIC("Syntax"), SEMANTIC, COMPLIANCE("Compliance");

        private String desc = null;

        private Kind() {}

        private Kind(String desc) {
            this.desc = desc;
        }

        public void writeKindAndSeverity(StringBuilder sb, Severity sev) {
            String s = sev.toString().toLowerCase();
            if (desc != null) {
                sb.append(desc);
                sb.append(' ');
                sb.append(s);
            } else {
                sb.append(Character.toUpperCase(s.charAt(0)));
                sb.append(s.substring(1));
            }
        }
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

    protected final Severity severity;
    public Severity severity() { return severity; }

    protected final Kind kind;
    public Kind kind() { return kind; }

    protected Set<String> components = new TreeSet<String>(); // TreeSet is used so that we get a sorted set

    public void addComponent(String component) {
        if (component != null)
            components.add(component);
    }

    public Collection<String> components() { return components; }

    public Problem(String fileName, String message) {
        this(fileName, message, Severity.ERROR);
    }

    public Problem(String fileName, String message, Severity severity) {
        this(fileName, message, severity, Kind.OTHER);
    }

    public Problem(String fileName, String message, Severity severity, Kind kind) {
        this(fileName, message, severity, kind, 0, 0);
    }

    public Problem(String fileName, String message, Severity severity, Kind kind, int beginLine, int beginColumn) {
        this.fileName = fileName;
        this.message = message;
        this.severity = severity;
        this.kind = kind;
        this.beginLine = beginLine;
        this.beginColumn = beginColumn;
        
        if (message == null)
            throw new NullPointerException();
    }

    public boolean isTestError(boolean checkAll) {
        return checkAll || (severity == Severity.ERROR && kind != Kind.COMPLIANCE);
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

    public String toString() {
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
        sb.append(message);
        return sb.toString();
    }

}

