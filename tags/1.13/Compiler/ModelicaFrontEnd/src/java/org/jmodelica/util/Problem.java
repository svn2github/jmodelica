package org.jmodelica.util;

public class Problem implements Comparable<Problem> {
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
    
    
    public String toString() {
        String kindStr = (kind == Kind.OTHER) ? "At " : capitalize(kind) + " error at ";
        return capitalize(severity) + ": in file '" + fileName + "':\n" + 
                kindStr + "line " + beginLine + ", column " + beginColumn + ":\n" + 
                "  " + message;
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

