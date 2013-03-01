package org.jmodelica.ide.editor;

public abstract class Indent {
    

	public static Indent INDENT    = new Indent() { public int modify(int indent, int indentWidth) { return indent + indentWidth; } };
    public static Indent SAME      = new Indent() { public int modify(int indent, int indentWidth) { return indent; } };
    public static Indent UNCHANGED = new Indent() { public int modify(int indent, int indentWidth) { return indent; } };
    public static Indent COMMENT   = new Indent() { public int modify(int indent, int indentWidth) { return indent + 3; } }; 
    
    public static class AnnotationParen extends Indent {
        int level;
        
        public AnnotationParen(int level) {
            this.level = level;
        }
        
        public int modify(int indent, int indentWidth) { return indent + level; }
        
        public boolean equals(Object o) { // for testing
            if (o == null || !(o instanceof AnnotationParen))
                return false;
            return ((AnnotationParen)o).level == level;
        }
        
        public String toString() {
            return String.format("AnnotationParen: Level=%d", level);
        }
    };
        
	public abstract int modify(int indent, int indentWidth);
} 
