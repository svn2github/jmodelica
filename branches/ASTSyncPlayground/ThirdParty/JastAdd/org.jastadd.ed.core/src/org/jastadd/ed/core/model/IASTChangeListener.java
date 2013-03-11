package org.jastadd.ed.core.model;

public interface IASTChangeListener {
	public static final int GRAPHICAL_LISTENER = 0;
	public static final int OUTLINE_LISTENER = 1;
	public static final int TEXTEDITOR_LISTENER = 2;

	public void astChanged(IASTChangeEvent e);
}
