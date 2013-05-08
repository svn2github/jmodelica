package org.jmodelica.ide.documentation.sync;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jmodelica.ide.documentation.HistoryObject;

public class RenderClassDeclEvent implements IASTChangeEvent {
	private String renderedClassDecl;
	private boolean setHistory;
	private HistoryObject history;

	/**
	 * Contains the result of a RenderclassDeclTask.
	 */
	public RenderClassDeclEvent(String renderedClassDecl,
			HistoryObject history, boolean setHistory) {
		this.history = history;
		this.setHistory = setHistory;
		this.renderedClassDecl = renderedClassDecl;
	}

	public String getRenderedClassDecl() {
		return renderedClassDecl;
	}

	public HistoryObject getHistoryObject() {
		return history;
	}

	public boolean getSetHistory() {
		return setHistory;
	}

	@Override
	public int getLevel() {
		return 0;
	}

	@Override
	public Stack<Integer> getChangedPath() {
		return null;
	}

	@Override
	public IFile getFile() {
		return null;
	}

	@Override
	public int getType() {
		return 0;
	}
}