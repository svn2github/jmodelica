package org.jmodelica.api.problemHandling;

public enum ProblemKind { 
    OTHER(2), LEXICAL("Syntax", 1), SYNTACTIC("Syntax", 1), SEMANTIC(2), COMPLIANCE("Compliance", 2);

    private String desc = null;
    public final int order;

    private ProblemKind(int order) {
        this.order = order;
    }

    private ProblemKind(String desc, int order) {
        this.desc = desc;
        this.order = order;
    }

    public void writeKindAndSeverity(StringBuilder sb, ProblemSeverity sev) {
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