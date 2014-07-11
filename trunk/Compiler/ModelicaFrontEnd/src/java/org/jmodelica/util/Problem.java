package org.jmodelica.util;

import java.io.Serializable;
import java.util.Collection;
import java.util.Set;
import java.util.TreeSet;

public class Problem implements Comparable<Problem>, Serializable {
    private static final long serialVersionUID = 1;
    
    public int compareTo(Problem o) {
        Problem other = (Problem)o;
        if(!fileName.equals(other.fileName))
            return fileName.compareTo(other.fileName);
        if(!(beginLine == other.beginLine))
            return beginLine > other.beginLine? 1 : -1;
        if(!(beginColumn == other.beginColumn))
            return beginColumn > other.beginColumn? 1 : -1;
        return message.compareTo(other.message);
    }
    public enum Severity { ERROR, WARNING }
    public enum Kind { OTHER, LEXICAL, SYNTACTIC, SEMANTIC, COMPLIANCE }
    protected int beginLine = 0;
    protected int beginColumn = 0;
    public int beginLine() { return beginLine; }
    public void setBeginLine(int beginLine) { this.beginLine = beginLine; }
    public int beginColumn() { return beginColumn; }
    public void setBeginColumn(int beginColumn) { this.beginColumn = beginColumn; }
  
    protected String fileName;
    public String fileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }
    protected String message;
    public String message() { return message; }
    protected Severity severity = Severity.ERROR;
    public Severity severity() { return severity; }
    protected Kind kind = Kind.OTHER;
    public Kind kind() { return kind; }
    protected Set<String> components = new TreeSet<String>(); // TreeSet is used so that we get a sorted set
    public void addComponent(String component) {
        if (component != null)
            components.add(component);
    }
    public Collection<String> components() { return components; }
    
    public Problem(String fileName, String message) {
        this.fileName = fileName;
        this.message = message;
    }
    public Problem(String fileName, String message, Severity severity) {
        this(fileName, message);
        this.severity = severity;
    }
    public Problem(String fileName, String message, Severity severity, Kind kind) {
        this(fileName, message, severity);
        this.kind = kind;
    }
    
    public Problem(String fileName, String message, Severity severity, Kind kind, int beginLine, int beginColumn) {
        this(fileName, message, severity);
        this.kind = kind;
        this.beginLine = beginLine;
        this.beginColumn = beginColumn;
    }
    
    public boolean isTestError(boolean checkAll) {
        return checkAll || (severity == Severity.ERROR && kind != Kind.COMPLIANCE);
    }
    
    public boolean equals(Object o) {
        return (o instanceof Problem) && (compareTo((Problem)o) == 0);
    }
    
    public static String capitalize(Object o) {
        String name = o.toString();
        return name.charAt(0) + name.substring(1).toLowerCase();
    }
    
    public void merge(Problem p) {
        components.addAll(p.components);
    }
    
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(capitalize(severity));
        sb.append(": in file '");
        sb.append(fileName);
        sb.append("'");
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
                    sb.append("  ");
                    sb.append(component);
                    sb.append("\n");
                    if (i == limit) break;
                }
                if (components.size() > limit) {
                    sb.append(".. and ");
                    sb.append(components.size() - limit);
                    sb.append(" additional components\n");
                }
            } else {
                sb.append("In component ");
                sb.append(components.iterator().next());
                sb.append("\n");
            }
        } else {
            sb.append(":\n");
        }
        if (kind == Kind.OTHER) {
            sb.append("At ");
        } else {
            sb.append(capitalize(kind));
            sb.append(" error at ");
        }
        sb.append("line ");
        sb.append(beginLine);
        sb.append(", column ");
        sb.append(beginColumn);
        sb.append(":\n  ");
        sb.append(message);
        return sb.toString();
    }
    
//    public String toXML() {
//        return String.format(
//                "<%s>\n" +
//                "    <value name=\"kind\">%s</value>\n" +
//                "    <value name=\"file\">%s</value>\n" +
//                "    <value name=\"line\">%s</value>\n" +
//                "    <value name=\"column\">%s</value>\n" +
//                "    <value name=\"message\">%s</value>\n" +
//                "</%1$s>",
//                XMLUtil.escape(name(severity)),
//                XMLUtil.escape(kind.toString().toLowerCase()),
//                XMLUtil.escape(fileName),
//                beginLine, beginColumn,
//                XMLUtil.escape(message)
//        );
//    }
}

