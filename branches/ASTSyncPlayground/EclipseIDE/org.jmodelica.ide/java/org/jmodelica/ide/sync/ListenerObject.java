package org.jmodelica.ide.sync;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeListener;
import org.jmodelica.ide.sync.tasks.NotifyGraphicalTask;
import org.jmodelica.ide.sync.tasks.NotifyOutlineTask;

public class ListenerObject {
	private IASTChangeListener listener;
	private int listenerType;
	private int listenerID;

	public ListenerObject(IASTChangeListener listener, int listenerType) {
		this.listener = listener;
		this.listenerType = listenerType;
	}

	public ListenerObject(IASTChangeListener listener, int listenerType, int id) {
		this(listener, listenerType);
		listenerID = id;
	}

	public void doUpdate(IFile file, int astChangeEventType, Stack<String> changedPath) {
		if (listenerType == IASTChangeListener.GRAPHICAL_LISTENER) {
			NotifyGraphicalTask ug = new NotifyGraphicalTask(astChangeEventType,
					listener, changedPath, listenerID);
			ASTRegTaskBucket.getInstance().addTask(ug);
		} else if (listenerType == IASTChangeListener.OUTLINE_LISTENER) {
			NotifyOutlineTask uo = new NotifyOutlineTask(file, astChangeEventType,
					listener, listenerID);
			ASTRegTaskBucket.getInstance().addTask(uo);
		} else if (listenerType == IASTChangeListener.TEXTEDITOR_LISTENER) {
			// TODO for AST driven text editor...
		}
	}

	public boolean equals(IASTChangeListener other) {
		return this.listener == other;
	}
}