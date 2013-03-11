package org.jmodelica.ide.compiler;

import java.util.Stack;

import org.jastadd.ed.core.model.IASTChangeListener;

public class ListenerObject {
	private IASTChangeListener listener;
	private int listenerType;

	public ListenerObject(IASTChangeListener listener, int listenerType) {
		this.listener = listener;
		this.listenerType = listenerType;
	}

	public void doUpdate(Stack<String> changedPath) {
		if (listenerType == IASTChangeListener.GRAPHICAL_LISTENER) {
			UpdateGraphicalJob ug = new UpdateGraphicalJob(listener,
					changedPath);
			ModelicaASTRegistryJobBucket.getInstance().addJob(ug);
		} else if (listenerType == IASTChangeListener.OUTLINE_LISTENER) {
			UpdateOutlineJob uo = new UpdateOutlineJob(listener, changedPath);
			ModelicaASTRegistryJobBucket.getInstance().addJob(uo);
		} else if (listenerType == IASTChangeListener.TEXTEDITOR_LISTENER) {
			// TODO
		}
	}
}