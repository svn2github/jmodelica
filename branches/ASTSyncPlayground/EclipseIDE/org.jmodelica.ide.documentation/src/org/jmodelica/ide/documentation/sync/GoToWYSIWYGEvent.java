package org.jmodelica.ide.documentation.sync;

import java.util.Stack;

import org.eclipse.core.resources.IFile;
import org.jastadd.ed.core.model.IASTChangeEvent;

public class GoToWYSIWYGEvent implements IASTChangeEvent {
	private String fileUrl;

	public GoToWYSIWYGEvent(String fileUrl) {
		this.fileUrl = fileUrl;
	}

	public String getFileUrl() {
		return fileUrl;
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