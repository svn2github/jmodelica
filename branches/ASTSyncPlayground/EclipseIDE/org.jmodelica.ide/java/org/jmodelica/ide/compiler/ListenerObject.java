package org.jmodelica.ide.compiler;

import java.util.Stack;

import org.jastadd.ed.core.model.IASTChangeListener;

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

	public void doUpdate(Stack<String> changedPath) {
		if (listenerType == IASTChangeListener.GRAPHICAL_LISTENER) {
			UpdateGraphicalJob ug = new UpdateGraphicalJob(listener,
					changedPath, listenerID);
			ModelicaASTRegistryJobBucket.getInstance().addJob(ug);
		} else if (listenerType == IASTChangeListener.OUTLINE_LISTENER) {
			UpdateOutlineJob uo = new UpdateOutlineJob(listener, changedPath,
					listenerID);
			ModelicaASTRegistryJobBucket.getInstance().addJob(uo);
		} else if (listenerType == IASTChangeListener.TEXTEDITOR_LISTENER) {
			// TODO
		}
	}

	public boolean equals(IASTChangeListener other) {
		return this.listener == other;
	}
}