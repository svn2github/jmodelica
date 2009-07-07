package org.jmodelica.ide.indent;

public enum Indent { 
	INDENT	{ public int modify(int indent, int tabWidth) { return indent + tabWidth; } },
	SAME	{ public int modify(int indent, int tabWidth) { return indent; } },
	NONE	{ public int modify(int indent, int tabWidth) { return 0; } },
	COMMENT	{ public int modify(int indent, int tabWidth) { return indent + 3; } };
	public abstract int modify(int indent, int tabWidth);
} 
