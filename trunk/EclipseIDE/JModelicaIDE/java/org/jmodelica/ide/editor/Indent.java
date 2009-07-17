package org.jmodelica.ide.editor;

public enum Indent { 
	INDENT	{ public int modify(int indent, int indentWidth) { return indent + indentWidth; } },
	SAME	{ public int modify(int indent, int indentWidth) { return indent; } },
	NONE	{ public int modify(int indent, int indentWidth) { return 0; } },
	COMMENT	{ public int modify(int indent, int indentWidth) { return indent + 3; } };
	public abstract int modify(int indent, int indentWidth);
} 
